#
# Cookbook:: postgresql
# Library:: sql/_utils
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

module PostgreSQL
  module Cookbook
    module SqlHelpers
      module Utils
        private

        include PostgreSQL::Cookbook::Utils

        def config_string_to_hash(string)
          return {} if nil_or_empty?(string)

          config_string = string.dup
          config_string.delete_prefix!('{')
          config_string.delete_suffix!('}')
          config_string = config_string.split(',').map { |rcv| rcv.split('=') }.to_h

          config_string.transform_values! do |v|
            case v
            when 'on'
              true
            when 'off'
              false
            else v
            end
          end

          config_string
        end

        def map_pg_values!(hash)
          raise ArgumentError unless hash.is_a?(Hash)

          hash.transform_values! do |v|
            case v
            when 't'
              true
            when 'f'
              false
            else
              v
            end
          end
        end
      end
    end
  end
end
