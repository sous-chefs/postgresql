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
          name_property: true,
          description: 'The name of the extension to be installed'

property :schema, String,
          description: 'The name of the schema in which to install the extension objects'

property :old_version, String,
          description: 'old_version must be specified when, and only when, you are attempting to install an extension that replaces an "old style" module that is just a collection of objects not packaged into an extension.'

property :version, String,
          description: 'The version of the extension to install'

property :cascade, [true, false],
          description: 'Automatically install any extensions that this extension depends on that are not already installed'

property :restrict, [true, false],
          description: 'This option prevents the specified extensions from being dropped if other objects, besides these extensions, their members, and their explicitly dependent routines, depend on them'

include PostgreSQL::Cookbook::SqlHelpers::Extension

load_current_value do |new_resource|
  current_value_does_not_exist! unless pg_extension?(new_resource)

  extension_data = pg_extension(new_resource.extension)

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
