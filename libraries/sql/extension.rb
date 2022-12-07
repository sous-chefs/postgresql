#
# Cookbook:: postgresql
# Library:: sql/extension
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

module PostgreSQL
  module Cookbook
    module SqlHelpers
      module Extension
        private

        include PostgreSQL::Cookbook::Utils
        include PostgreSQL::Cookbook::SqlHelpers::Connection

        def pg_extension(name)
          sql = 'SELECT * FROM pg_extension WHERE extname=$1'

          execute_sql_params(sql, [ name ], max_one_result: true).pop
        end

        def pg_extension?(new_resource)
          sql = 'SELECT extversion FROM pg_extension WHERE extname=$1'
          version = execute_sql_params(sql, [ new_resource.extension ], max_one_result: true)

          return false if nil_or_empty?(version)

          version = version.pop

          if new_resource.version
            return version.fetch('extversion').eql?(new_resource.version)
          end

          !version.empty?
        end

        def create_extension(new_resource)
          sql = []

          sql.push("CREATE EXTENSION \"#{new_resource.extension}\"")

          sql.push("SCHEMA \"#{new_resource.schema}\"") if property_is_set?(:schema)
          sql.push("VERSION \"#{new_resource.version}\"") if property_is_set?(:version)
          sql.push("FROM \"#{new_resource.old_version}\"") if property_is_set?(:old_version)
          sql.push('CASCADE') if new_resource.cascade

          execute_sql("#{sql.join(' ').strip};")
        end

        def drop_extension(new_resource)
          sql = []

          sql.push("DROP EXTENSION #{new_resource.extension}")
          sql.push('CASCADE') if new_resource.cascade
          sql.push('RESTRICT') if new_resource.restrict

          execute_sql("#{sql.join(' ').strip};")
        end
      end
    end
  end
end
