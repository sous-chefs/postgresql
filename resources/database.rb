#
# Cookbook:: postgresql
# Resource:: database
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
use 'partial/_connection'

property :database, String,
          name_property: true

property :owner, [String, Integer]

property :template, String,
          default: 'template1'

property :encoding, Integer

property :strategy, String

property :locale, String

property :lc_collate, String

property :lc_ctype, String

property :icu_locale, String

property :locale_provider, String

property :collation_version, String

property :tablespace, String

property :allow_connections, [true, false]

property :connection_limit, [Integer, String],
          default: -1,
          coerce: proc { |p| p.to_s }

property :is_template, [true, false]

include PostgreSQL::Cookbook::SqlHelpers

load_current_value do |new_resource|
  current_value_does_not_exist! unless pg_database?(new_resource.name)

  database_data = pg_database(new_resource.name)

  database(database_data.fetch('datname', nil))
  owner(database_data.fetch('datdba', nil))
  encoding(database_data.fetch('encoding', nil).to_i)
  lc_collate(database_data.fetch('datcollate', nil))
  lc_ctype(database_data.fetch('datctype', nil))
  icu_locale(database_data.fetch('daticulocale', nil))
  locale_provider(database_data.fetch('datlocprovider', nil))
  tablespace(database_data.fetch('dattablespace', nil))
  allow_connections(database_data.fetch('datallowconn', nil))
  connection_limit(database_data.fetch('datconnlimit', nil))
  is_template(database_data.fetch('datistemplate', nil))
end

action :create do
  converge_if_changed { create_database(new_resource) } unless pg_database?(new_resource.name)
end

action :update do
  raise CurrentValueDoesNotExist, "Cannot update database '#{new_resource.name}' as it does not exist" unless pg_database?(new_resource.name)

  converge_if_changed(:allow_connections, :connection_limit, :is_template) do
    update_database(new_resource)
  end

  converge_if_changed(:owner) do
    update_database_owner(new_resource)
  end

  converge_if_changed(:tablespace) do
    update_database_tablespace(new_resource)
  end
end

action :drop do
  converge_by("Drop database #{new_resource.name}") { drop_database(new_resource) } if pg_database?(new_resource.name)
end

action :delete do
  run_action(:drop)
end
