#
# Cookbook:: postgresql
# Library:: sql/database
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

require_relative '../_utils'
require_relative '_connection'
require_relative '_utils'

module PostgreSQL
  module Cookbook
    module SqlHelpers
      module Database
        private

        include PostgreSQL::Cookbook::Utils
        include PostgreSQL::Cookbook::SqlHelpers::Connection
        include Utils

        def pg_database(name)
          sql = 'SELECT * from pg_database WHERE datname=$1'
          params = [ name ]
          database = execute_sql_params(sql, params, max_one_result: true)

          return if database.to_a.empty?

          database = database.to_a.pop
          map_pg_values!(database)

          database
        end

        def pg_database?(name)
          !nil_or_empty?(pg_database(name))
        end

        def database_sql(new_resource)
          sql = []
          sql.push("DATABASE \"#{new_resource.database}\"")

          properties = case new_resource.action.pop
                       when :create
                         %i(
                           owner
                           template
                           encoding
                           strategy
                           locale
                           lc_collate
                           lc_ctype
                           icu_locale
                           locale_provider
                           collation_version
                           tablespace
                           allow_connections
                           connection_limit
                           is_template
                         )
                       when :update
                         %i(
                           allow_connections
                           connection_limit
                           is_template
                         )
                       end

          if properties.any? { |p| property_is_set?(p) }
            sql.push('WITH')

            properties.each do |p|
              next if nil_or_empty?(new_resource.send(p))

              property_string = if %i(allow_connections connection_limit is_template).include?(p) || p.is_a?(Integer)
                                  "#{p.to_s.upcase}=#{new_resource.send(p)}"
                                else
                                  "#{p.to_s.upcase}=\"#{new_resource.send(p)}\""
                                end

              sql.push(property_string)
            end
          end

          "#{sql.join(' ').strip};"
        end

        def create_database(new_resource)
          execute_sql("CREATE #{database_sql(new_resource)}")
        end

        def update_database(new_resource)
          execute_sql("ALTER #{database_sql(new_resource)}")
        end

        def update_database_owner(new_resource)
          execute_sql("ALTER DATABASE #{new_resource.database} OWNER TO #{new_resource.owner}")
        end

        def update_database_tablespace(new_resource)
          execute_sql("ALTER DATABASE #{new_resource.database} SET TABLESPACE #{new_resource.tablespace}")
        end

        def drop_database(new_resource)
          sql = "DROP DATABASE #{new_resource.database}"
          sql.concat(' WITH FORCE') if new_resource.force
          execute_sql(sql)
        end
      end
    end
  end
end
