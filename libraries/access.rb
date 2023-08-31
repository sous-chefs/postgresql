#
# Cookbook:: postgresql
# Library:: access
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require_relative '_utils'

module PostgreSQL
  module Cookbook
    module AccessHelpers
      module PgHbaTemplate
        def config_resource_init
          config_resource_create unless config_resource_exist?
        end

        def config_resource
          return unless config_resource_exist?

          find_resource!(:template, new_resource.config_file)
        end

        private

        def config_resource_exist?
          !find_resource!(:template, new_resource.config_file).nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def config_resource_create
          file = PostgreSQL::Cookbook::AccessHelpers::PgHba::PgHbaFile.new
          file.read!(new_resource.config_file) if ::File.exist?(new_resource.config_file)

          with_run_context(:root) do
            declare_resource(:template, new_resource.config_file) do
              cookbook new_resource.cookbook
              source new_resource.source

              owner new_resource.owner
              group new_resource.group
              mode new_resource.filemode
              sensitive new_resource.sensitive

              variables(pg_hba: file)

              action :create
              delayed_action :create
            end
          end
        end
      end

      module PgHba
        ENTRY_TYPES = %w(local host hostssl hostnossl hostgssenc hostnogssenc).freeze

        class PgHbaFile
          include PostgreSQL::Cookbook::Utils

          attr_reader :entries

          SPLIT_REGEX = %r{^(((?<type>local)\s+(?<database>[\w\-_,]+)\s+(?<user>[\w\d\-_.$,]+))|((?!local)(?<type>\w+)\s+(?<database>[\w\-_,]+)\s+(?<user>[\w\d\-_.$,]+)\s+(?<address>[\w\-.:\/]+)))\s+(?<auth_method>[\w-]+)(?<auth_options>(?:\s+#{AUTH_OPTION_REGEX})*)(?:\s*)(?<comment>#\s*.*)?$}.freeze
          private_constant :SPLIT_REGEX

          def initialize
            @entries = []
            @access_entries = []
          end

          def read!(file = 'pg_hba.conf', sort: false)
            raise ArgumentError, "File #{file} does not exist" unless ::File.exist?(file)

            @access_entries.concat(File.read(file).split("\n"))
            @access_entries.reject! { |l| l.start_with?('#') }
            @access_entries.reject!(&:empty?)
            @access_entries.map! { |l| l.gsub(/\s+/, ' ') }

            split_entries

            raise PgHbaInvalidEntryType unless entry_types_valid?

            marshall_entries
            sort! if sort

            self
          end

          def to_s(sort: false)
            sort! if sort
            @entries.map(&:to_s).join("\n")
          end

          def add(entry, position = nil)
            raise PgHbaInvalidEntryType unless entry.is_a?(PgHbaFileEntry)

            if position
              @entries.insert(position, entry)
            else
              @entries.push(entry)
            end

            @entries.uniq!
          end

          def remove(entry)
            raise PgHbaInvalidEntryType unless entry.is_a?(PgHbaFileEntry)

            @entries.reject! { |e| e.eql?(entry) }
          end

          def move(entry, position)
            raise PgHbaInvalidEntryType unless entry.is_a?(PgHbaFileEntry)

            index = @entries.index { |e| e.eql?(entry) }

            return unless entry && !entry.eql?(position)

            @entries.insert(position, @entries.delete_at(index))
          end

          def include?(entry)
            raise unless entry.is_a?(PgHbaFileEntry)

            @entries.any? { |e| e.eql?(entry) }
          end

          def entry(type, database, user, address = nil)
            entry = @entries.filter { |e| e.match?(type, database, user, address) }

            return if nil_or_empty?(entry)

            raise PgHbaFileDuplicateEntry, "Duplicate entries found for #{type}, #{database}, #{user}, #{address}" unless entry.one?

            entry.pop
          end

          def sort!
            @entries.sort_by!(&:type)
          end

          def self.read(file = 'pg_hba.conf', sort: false)
            pg_hba = new
            pg_hba.read!(file, sort: sort)

            pg_hba
          end

          private

          def entry_types_valid?
            return unless @access_entries

            @access_entries.all? { |entry| ENTRY_TYPES.include?(entry.fetch(:type)) }
          end

          def split_entries
            return if @access_entries.empty?

            @access_entries.map! { |entry| SPLIT_REGEX.match(entry).named_captures.compact.transform_keys(&:to_sym) }
          end

          def marshall_entries
            return if @access_entries.empty?

            @access_entries.each_with_index { |entry, index| @entries.push(PgHbaFileEntry.create(**entry, position: index)) }

            @entries
          end
        end

        class PgHbaFileEntry
          include PostgreSQL::Cookbook::Utils

          attr_reader :type, :comment, :position

          ENTRY_FIELD_FORMAT = {
            type: 8,
            database: 32,
            user: 32,
            address: 24,
            auth_method: 16,
            auth_options: 24,
            comment: 0,
          }.freeze
          private_constant :ENTRY_FIELD_FORMAT

          def initialize(type:, database:, user:, auth_method:, auth_options: nil, comment: nil, position: nil)
            @type = type
            @type.freeze

            @database = database
            @user = user
            @auth_method = auth_method
            @auth_options = PgHbaFileEntryAuthOptions.new(auth_options) if auth_options && !auth_options.empty?
            self.comment = comment
            @position = position
          end

          def to_s
            entry_string = ''
            ENTRY_FIELD_FORMAT.each do |field, ljust_count|
              value = respond_to?(field) ? send(field) : ''
              field_string = value.to_s.ljust(ljust_count)
              field_string += ' ' unless field_string.include?(' ') || field == :comment
              entry_string.concat(field_string)
            end

            entry_string.strip
          end

          def eql?(entry)
            return false unless self.class.eql?(entry.class)

            return true if self.class.const_get(:ENTRY_FIELDS).all? { |field| send(field).eql?(entry.send(field)) }

            false
          end

          def match?(type, database, user, address = nil)
            return true if @type.eql?(type) && @database.eql?(database) && @user.eql?(user) && (@address.eql?(address) || address.nil?)

            false
          end

          def update(auth_method: nil, auth_options: nil, comment: nil)
            @auth_method = auth_method if auth_method
            @auth_options = PgHbaFileEntryAuthOptions.new(auth_options) if auth_options && !auth_options.empty?
            self.comment = comment if comment

            self
          end

          def comment=(comment)
            @comment = comment
            @comment = "# #{@comment}" unless nil_or_empty?(@comment) || @comment.start_with?('#')
          end

          def self.create(**properties)
            raise PgHbaInvalidEntryType, "Invalid entry type #{properties.fetch(:type)}" unless ENTRY_TYPES.include?(properties.fetch(:type))

            case properties.fetch(:type)
            when 'local'
              PgHbaFileEntryLocal.new(**properties)
            when 'host', 'hostssl', 'hostnossl', 'hostgssenc', 'hostnogssenc'
              PgHbaFileEntryHost.new(**properties)
            end
          end
        end

        class PgHbaFileEntryLocal < PgHbaFileEntry
          attr_accessor :database, :user, :auth_method, :auth_options

          ENTRY_FIELDS = %i(type database user auth_method auth_options).freeze
          private_constant :ENTRY_FIELDS

          def initialize(type:, database:, user:, auth_method:, auth_options: nil, comment: nil, position: nil)
            raise PgHbaInvalidEntryType, "Invalid entry type #{properties.first}" unless type.eql?('local')

            super
          end

          def to_a
            [@type, @database, @user, @auth_method, @auth_options.to_s, @comment]
          end
        end

        class PgHbaFileEntryHost < PgHbaFileEntry
          attr_accessor :database, :user, :address, :auth_method, :auth_options

          ENTRY_FIELDS = %i(type database user address auth_method auth_options).freeze
          private_constant :ENTRY_FIELDS

          def initialize(type:, database:, user:, address:, auth_method:, auth_options: nil, comment: nil, position: nil)
            raise PgHbaInvalidEntryType unless %w(host hostssl hostnossl hostgssenc hostnogssenc).include?(type)

            super(type: type, database: database, user: user, auth_method: auth_method, auth_options: auth_options, comment: comment, position: position)
            @address = address
          end

          def to_a
            [@type, @database, @user, @address, @auth_method, @auth_options.to_s, @comment]
          end
        end

        class PgHbaFileEntryAuthOptions
          include PostgreSQL::Cookbook::Utils

          attr_reader :options

          def initialize(options_string)
            @options = options_string_parse(options_string)
          end

          def to_h
            @options.to_h
          end

          def to_s
            @options.map do |k, v|
              raise "Nil key or value received when processing #{@options}" if k.nil? || v.nil?

              "#{k}=#{v}"
            end.join(' ')
          end

          def eql?(auth_options)
            case auth_options
            when self.class
              @options.eql?(auth_options.options)
            when Hash
              @options.eql?(auth_options)
            when String
              to_s.eql?(options_string_parse(auth_options))
            else
              false
            end
          end

          private

          def options_string_parse(string)
            string.scan(AUTH_OPTION_REGEX).sort!.map! { |s| s.split('=', 2) }
          end
        end

        class PgHbaInvalidEntryType < StandardError; end
        class PgHbaFileDuplicateEntry < StandardError; end
      end
    end
  end
end
