# frozen_string_literal: true
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

property :database,    String, required: true
property :extension,   String, name_property: true
property :old_version, String

action :create do
  create_query = "CREATE EXTENSION IF NOT EXISTS \"#{new_resource.extension}\""
  create_query << " FROM \"#{new_resource.old_version}\"" if property_is_set?(:old_version)
  bash "CREATE EXTENSION #{new_resource.name}" do
    code psql_command_string(new_resource.database, create_query)
    user 'postgres'
    action :run
    not_if { slave? || extension_installed? }
  end
end

action :drop do
  bash "DROP EXTENSION #{new_resource.name}" do
    code psql_command_string(new_resource.database, "DROP EXTENSION IF EXISTS \"#{new_resource.extension}\"")
    user 'postgres'
    action :run
    not_if { slave? }
    only_if { extension_installed? }
  end
end

action_class do
  include PostgresqlCookbook::Helpers
end
