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

unified_mode true

use 'partial/_connection'

property :database, String,
          name_property: true,
          description: 'The name of a database to create'

property :owner, [String, Integer],
          description: 'The role name of the user who will own the new database, or DEFAULT to use the default (namely, the user executing the command). To create a database owned by another role, you must be a direct or indirect member of that role, or be a superuser.'

property :template, String,
          default: 'template1',
          description: 'The name of the template from which to create the new database, or DEFAULT to use the default template (template1)'

property :encoding, [Integer, String],
          description: 'Character set encoding to use in the new database'

property :strategy, String,
          description: 'Strategy to be used in creating the new database'

property :locale, String,
          description: 'This is a shortcut for setting LC_COLLATE and LC_CTYPE at once'

property :lc_collate, String,
          description: 'Collation order (LC_COLLATE) to use in the new database. This affects the sort order applied to strings, e.g., in queries with ORDER BY, as well as the order used in indexes on text columns. The default is to use the collation order of the template database.'

property :lc_ctype, String,
          description: 'Character classification (LC_CTYPE) to use in the new database. This affects the categorization of characters, e.g., lower, upper and digit. The default is to use the character classification of the template database.'

property :icu_locale, String,
          description: 'Specifies the ICU locale ID if the ICU locale provider is used'

property :locale_provider, String,
          description: 'Specifies the provider to use for the default collation in this database'

property :collation_version, String,
          description: 'Specifies the collation version string to store with the database'

property :tablespace, String,
          description: 'The name of the tablespace that will be associated with the new database'

property :allow_connections, [true, false],
          default: true,
          description: 'If false then no one can connect to this database'

property :connection_limit, [Integer, String],
          default: -1,
          coerce: proc { |p| p.to_s },
          description: 'How many concurrent connections can be made to this database. -1 (the default) means no limit.'

property :is_template, [true, false],
          description: 'If true, then this database can be cloned by any user with CREATEDB privileges; if false (the default), then only superusers or the owner of the database can clone it.'

include PostgreSQL::Cookbook::SqlHelpers::Database

load_current_value do |new_resource|
  current_value_does_not_exist! unless pg_database?(new_resource.database)

  database_data = pg_database(new_resource.database)

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

action_class do
  include PostgreSQL::Cookbook::SqlHelpers::Database
end

action :create do
  converge_if_changed { create_database(new_resource) } unless pg_database?(new_resource.database)
end

action :update do
  raise Chef::Exceptions::CurrentValueDoesNotExist, "Cannot update database '#{new_resource.database}' as it does not exist" unless pg_database?(new_resource.database)

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
  converge_by("Drop database #{new_resource.database}") { drop_database(new_resource) } if pg_database?(new_resource.database)
end

action :delete do
  run_action(:drop)
end
