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

property :extension,        String, name_property: true
property :old_version,      String
property :version,          String

# Connection prefernces
property :user,     String, default: 'postgres'
property :database, String, required: true
property :host,     [String, nil]
property :port,     Integer, default: 5432

action :create do
  bash "CREATE EXTENSION #{new_resource.name}" do
    code create_extension_sql(new_resource)
    user 'postgres'
    action :run
    not_if { follower? || extension_installed?(new_resource) }
  end
end

action :drop do
  bash "DROP EXTENSION #{new_resource.name}" do
    code psql_command_string(new_resource, "DROP EXTENSION IF EXISTS \"#{new_resource.extension}\"")
    user 'postgres'
    action :run
    not_if { follower? }
    only_if { extension_installed?(new_resource) }
  end
end

action_class do
  include PostgresqlCookbook::Helpers
end
