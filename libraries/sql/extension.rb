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

require_relative '_connection'

module PostgreSQL
  module Cookbook
    module SqlHelpers
      module Extension
        include PostgreSQL::Cookbook::SqlHelpers::Connection

        private

        def pg_extension(name)
          sql = "SELECT * FROM pg_extension WHERE extname='#{name}';"

          execute_sql(sql, max_one_result: true).pop
        end

        def pg_extension?(new_resource)
          sql = "SELECT extversion FROM pg_extension WHERE extname='#{new_resource.extension}';"
          version = execute_sql(sql, max_one_result: true).pop

          if new_resource.version
            return version.fetch('extversion').eql?(new_resource.version)
          end

          !version.empty?
        end

        def create_extension(new_resource)
          sql = []

          sql.push("CREATE EXTENSION '#{new_resource.extension}'")
          sql.push("FROM '#{new_resource.old_version}'") if property_is_set?(new_resource.old_version)

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
