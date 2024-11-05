#
# Cookbook:: postgresql
# Library:: ident
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
    module IdentHelpers
      module PgIdentTemplate
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
          file = PostgreSQL::Cookbook::IdentHelpers::PgIdent::PgIdentFile.new
          file.read!(new_resource.config_file) if ::File.exist?(new_resource.config_file)

          with_run_context(:root) do
            declare_resource(:template, new_resource.config_file) do
              cookbook new_resource.cookbook
              source new_resource.source

              owner new_resource.owner
              group new_resource.group
              mode new_resource.filemode
              sensitive new_resource.sensitive

              variables(pg_ident: file)

              action :create
              delayed_action :create
            end
          end
        end
      end

      module PgIdent
        class PgIdentFile
          include PostgreSQL::Cookbook::Utils

          attr_reader :entries

          SPLIT_REGEX = /^(?<map_name>[\w-]+)\s+(?<system_username>[\w-]+)\s+(?<database_username>[\w-]+)(?:\s*)(?<comment>#\s*.*)?$/
          private_constant :SPLIT_REGEX

          def initialize
            @entries = []
            @ident_entries = []
          end

          def add(entry)
            raise unless entry.is_a?(PgIdentFileEntry)

            return false if entry?(entry.map_name)

            @entries.push(entry)

            sort!
          end

          def entry(map_name)
            entry = @entries.filter { |e| e.map_name.eql?(map_name) }

            return if nil_or_empty?(entry)

            raise PgIdentFileDuplicateEntry, "Duplicate entries found for #{map_name}" unless entry.one?

            entry.pop
          end

          def entry?(map_name)
            !@entries.filter { |e| e.map_name.eql?(map_name) }.empty?
          end

          def include?(entry)
            raise unless entry.is_a?(PgIdentFileEntry)

            @entries.any? { |e| e.map_name.eql?(entry.map_name) }
          end

          def read!(file = 'pg_ident.conf', sort: true)
            raise ArgumentError, "File #{file} does not exist" unless ::File.exist?(file)

            @ident_entries.concat(File.read(file).split("\n"))
            @ident_entries.reject! { |l| l.start_with?('#') }
            @ident_entries.reject!(&:empty?)
            @ident_entries.map! { |l| l.gsub(/\s+/, ' ') }

            split_entries

            marshall_entries
            sort! if sort
          end

          def remove(entry)
            raise unless entry.is_a?(PgIdentFileEntry) || entry.is_a?(String)

            remove_name = case entry
                          when PgIdentFileEntry
                            entry.map_name
                          when String
                            entry
                          end

            @entries.reject! { |e| e.map_name.eql?(remove_name) }
          end

          def sort!
            @entries.sort_by!(&:map_name)
          end

          def to_s(sort: true)
            sort! if sort
            @entries.map(&:to_s).join("\n")
          end

          def self.read(file = 'pg_ident.conf', sort: true)
            pg_hba = new
            pg_hba.read!(file, sort:)

            pg_hba
          end

          private

          def split_entries
            return if @ident_entries.empty?

            @ident_entries.map! { |entry| SPLIT_REGEX.match(entry).named_captures.compact.transform_keys(&:to_sym) }
          end

          def marshall_entries
            return if @ident_entries.empty?

            @ident_entries.each { |entry| @entries.push(PgIdentFileEntry.new(**entry)) }

            @entries
          end
        end

        class PgIdentFileEntry
          include PostgreSQL::Cookbook::Utils

          attr_reader :map_name, :system_username, :database_username, :comment

          ENTRY_FIELD_FORMAT = {
            map_name: 16,
            system_username: 24,
            database_username: 24,
            comment: 0,
          }.freeze
          ENTRY_FIELDS = ENTRY_FIELD_FORMAT.keys.dup.freeze

          private_constant :ENTRY_FIELD_FORMAT, :ENTRY_FIELDS

          def initialize(map_name:, system_username:, database_username:, comment: nil)
            @map_name = map_name
            @system_username = system_username
            @database_username = database_username
            @comment = comment
          end

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

          def update(system_username:, database_username:, comment:)
            @system_username = system_username if system_username
            @database_username = database_username if database_username
            self.comment = comment if comment

            self
          end

          def comment=(comment)
            @comment = comment
            @comment = "# #{@comment}" unless nil_or_empty?(@comment) || @comment.start_with?('#')
          end
        end

        class PgIdentFileDuplicateEntry < StandardError; end
      end
    end
  end
end
