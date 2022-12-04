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

        def pg_extension?(new_resource)
          query = %(SELECT extversion FROM pg_extension WHERE extname='#{new_resource.extension}';)
          check_extension_version = psql_command_string(new_resource, query, value_only: true)
          version_result = execute_sql(new_resource, check_extension_version)
          if new_resource.version
            version_result.stdout == new_resource.version
          else
            !version_result.stdout.chomp.empty?
          end
        end
      end
    end
  end
end
