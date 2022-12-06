#
# Cookbook:: postgresql
# Library:: sql/attribute
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
require_relative '_utils'

module PostgreSQL
  module Cookbook
    module SqlHelpers
      module Attribute
        private

        include PostgreSQL::Cookbook::SqlHelpers::Connection

        def pg_attribute?(role, attribute, value)
          sql = 'SELECT rolconfig FROM pg_roles WHERE rolname=$1'
          attribute_config = execute_sql_params(sql, [ role ], max_one_result: true).fetch('rolconfig')
          Chef::Log.warn("AC: #{attribute_config}")

          attribute_config = config_string_to_hash(attribute_config)
          map_pg_values!(attribute_config)

          Chef::Log.warn("AC Parsed: #{attribute_config}")
          Chef::Log.warn("AC Testing: #{attribute} | #{value}")

          attribute_config.fetch(attribute).eql?(value)
        end
      end
    end
  end
end
