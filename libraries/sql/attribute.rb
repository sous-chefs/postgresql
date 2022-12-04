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

module PostgreSQL
  module Cookbook
    module SqlHelpers
      module Attribute
        include PostgreSQL::Cookbook::SqlHelpers::Connection

        private

        def pg_attribute?(role, attribute, value)
          sql = %(SELECT rolconfig FROM pg_roles WHERE rolname='#{role}';)
          attribute_config = execute_sql(sql, max_one_result: true).fetch('rolconfig')
          Chef::Log.warn("AC: #{attribute_config}")

          attribute_config.delete_prefix!('{')
          attribute_config.delete_suffix!('}')
          attribute_config = attribute_config.split(',').map { |rcv| rcv.split('=') }.to_h
          attribute_config.transform_values! do |v|
            case v
            when 'on'
              true
            when 'off'
              false
            else v
            end
          end

          Chef::Log.warn("AC Parsed: #{attribute_config}")
          Chef::Log.warn("AC Testing: #{attribute} | #{value}")

          attribute_config.fetch(attribute).eql?(value)
        end
      end
    end
  end
end
