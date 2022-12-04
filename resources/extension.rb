#
# Cookbook:: postgresql
# Resource:: extension
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

unified_mode true

use 'partial/_connection'

property :extension, String,
          name_property: true

property :old_version, String

property :version, String

property :cascade, [true, false]

property :restrict, [true, false]

include PostgreSQL::Cookbook::SqlHelpers::Extension

load_current_value do |new_resource|
  current_value_does_not_exist! unless pg_extension?(new_resource)

  extension_data = pg_extension(new_resource.name)

  version(extension_data.fetch('extversion', nil))
end

action_class do
  include PostgreSQL::Cookbook::SqlHelpers::Extension
end

action :create do
  converge_if_changed { create_extension(new_resource) }
end

action :drop do
  converge_by("Drop extension #{new_resource.extension}") { drop_extension(new_resource) } if pg_extension?(new_resource)
end

action :delete do
  run_action(:drop)
end
