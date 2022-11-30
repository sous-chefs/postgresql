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

              action :nothing
              delayed_action :create
            end
          end
        end
      end

      module PgHba
        ENTRY_TYPES = %w(local host hostssl hostnossl hostgssenc hostnogssenc).freeze

        class PgHbaFile
          attr_reader :entries

          def initialize
            @entries = []
            @access_entries = []
          end

          def read!(file = 'pg_hba.conf', sort: true)
            raise ArgumentError, "File #{file} does not exist" unless ::File.exist?(file)

            @access_entries.concat(File.read(file).split("\n"))
            @access_entries.reject! { |l| l.start_with?('#') }
            @access_entries.reject!(&:empty?)
            @access_entries.map! { |l| l.gsub(/\s+/, ' ') }

            split_entries

            raise PgHbaInvalidEntryType unless entry_types_valid?

            marshall_entries
            sort! if sort
          end

          def to_s(sort: true)
            sort! if sort
            @entries.map(&:to_s).join("\n")
          end

          def add(entry)
            raise PgHbaInvalidEntryType unless entry.is_a?(PgHbaFileEntry)

            @entries.push(entry)
            sort!
          end

          def remove(entry)
            raise PgHbaInvalidEntryType unless entry.is_a?(PgHbaFileEntry)

            @entries.reject! { |e| e.eql?(entry) }
          end

          def include?(entry)
            raise unless entry.is_a?(PgHbaFileEntry)

            @entries.any? { |e| e.eql?(entry) }
          end

          def sort!
            @entries.sort_by!(&:type)
          end

          def self.read(file = 'pg_hba.conf', sort: true)
            pg_hba = new
            pg_hba.read!(file, sort: sort)

            pg_hba
          end

          private

          def entry_types_valid?
            return unless @access_entries

            @access_entries.all? { |ae| ENTRY_TYPES.include?(ae.first) }
          end

          def split_entries
            @access_entries.map! do |entry|
              if entry.start_with?('local')
                entry.split(nil, 5)
              elsif entry.start_with?('host', 'hostssl', 'hostnossl', 'hostgssenc', 'hostnogssenc')
                entry.split(nil, 6)
              end
            end
          end

          def marshall_entries
            @access_entries.each do |entry|
              e = case entry.first
                  when 'local'
                    PgHbaFileEntryLocal.new(*entry)
                  when 'host', 'hostssl', 'hostnossl', 'hostgssenc', 'hostnogssenc'
                    PgHbaFileEntryHost.new(*entry)
                  end

              @entries.push(e)
            end

            @entries
          end
        end

        class PgHbaFileEntry
          attr_reader :type

          ENTRY_FIELD_FORMAT = {
            type: 8,
            database: 16,
            user: 16,
            address: 24,
            auth_method: 8,
            auth_options: 0,
          }.freeze
          private_constant :ENTRY_FIELD_FORMAT

          def initialize; end

          def to_s
            entry_string = ''
            ENTRY_FIELD_FORMAT.each do |field, ljust_count|
              field = respond_to?(field) ? send(field) : ''
              field_string = field.to_s.ljust(ljust_count)
              entry_string.concat(field_string)
            end

            entry_string.strip
          end

          def eql?(entry)
            return false unless self.class.eql?(entry.class)

            return true if self.class.const_get(:ENTRY_FIELDS).all? { |field| send(field).eql?(entry.send(field)) }

            false
          end

          def self.create(*properties)
            raise PgHbaInvalidEntryType, "Invalid entry type #{properties.first}" unless ENTRY_TYPES.include?(properties.first)

            case properties.first
            when 'local'
              PgHbaFileEntryLocal.new(*properties)
            when 'host', 'hostssl', 'hostnossl', 'hostgssenc', 'hostnogssenc'
              PgHbaFileEntryHost.new(*properties)
            end
          end
        end

        class PgHbaFileEntryLocal < PgHbaFileEntry
          attr_accessor :database, :user, :auth_method, :auth_options

          ENTRY_FIELDS = %i(type database user auth_method auth_options).freeze
          private_constant :ENTRY_FIELDS

          def initialize(type, database, user, auth_method, auth_options = nil)
            raise PgHbaInvalidEntryType, "Invalid entry type #{properties.first}" unless type.eql?('local')

            @type = type
            @type.freeze

            @database = database
            @user = user
            @auth_method = auth_method
            @auth_options = auth_options
            @auth_options = PgHbaFileEntryAuthOptions.new(auth_options) if auth_options
          end

          def to_a
            [@type, @database, @user, @auth_method, @auth_options.to_s]
          end
        end

        class PgHbaFileEntryHost < PgHbaFileEntry
          attr_accessor :database, :user, :address, :auth_method, :auth_options

          ENTRY_FIELDS = %i(type database user address auth_method auth_options).freeze
          private_constant :ENTRY_FIELDS

          def initialize(type, database, user, address, auth_method, auth_options = nil)
            raise PgHbaInvalidEntryType unless %w(host hostssl hostnossl hostgssenc hostnogssenc).include?(type)

            @type = type
            @type.freeze

            @database = database
            @user = user
            @address = address
            @auth_method = auth_method
            @auth_options = auth_options
            @auth_options = PgHbaFileEntryAuthOptions.new(auth_options) if auth_options
          end

          def to_a
            [@type, @database, @user, @address, @auth_method, @auth_options.to_s]
          end
        end

        class PgHbaFileEntryAuthOptions
          attr_reader :options

          def initialize(options_string)
            @options = options_string_parse(options_string)
          end

          def to_h
            @options.to_h
          end

          def to_s
            @options.map { |k, v| "#{k}=#{v}" }.join(' ')
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
            string.split.map { |kv| kv.split('=') }.sort
          end
        end

        class PgHbaInvalidEntryType < StandardError; end
      end
    end
  end
end
