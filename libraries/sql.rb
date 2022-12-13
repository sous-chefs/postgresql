#
# Cookbook:: postgresql
# Library:: sql
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

require_relative 'sql/_connection'
require_relative 'sql/_utils'
require_relative 'sql/attribute'
require_relative 'sql/database'
require_relative 'sql/extension'
require_relative 'sql/role'

module PostgreSQL
  module Cookbook
    module SqlHelpers
      include Connection
      include Attribute
      include Database
      include Extension
      include Role
    end
  end
end
