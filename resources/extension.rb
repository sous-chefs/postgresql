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

# name property should take the form:
# database/extension

property :database, String, required: true, default: lazy { name.scan(%r{\A[^/]+(?=/)}).first }
property :extension, String, name_property: true, default: lazy { name.scan(%r{(?<=/)[^/]+\Z}).first }

action :create do
  bash "CREATE EXTENSION #{new_resource.name}" do
    code psql("CREATE EXTENSION IF NOT EXISTS \"#{new_resource.extension}\"")
    user 'postgres'
    action :run
    not_if { extension_installed? }
  end
end

action :drop do
  bash "DROP EXTENSION #{new_resource.name}" do
    code psql("DROP EXTENSION IF EXISTS \"#{new_resource.extension}\"")
    user 'postgres'
    action :run
    only_if { extension_installed? }
  end
end

action_class do
  include PostgresqlCookbook::Helpers

  def psql(query)
    "psql -d #{new_resource.database} <<< '\\set ON_ERROR_STOP on\n#{query};'"
  end

  def extension_installed?
    query = "SELECT 'installed' FROM pg_extension WHERE extname = '#{new_resource.extension}';"
    !(execute_sql(query, new_resource.database) =~ /^installed$/).nil?
  end
end
