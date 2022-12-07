#
# Cookbook:: postgresql
# Resource:: role
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

provides :postgresql_user

use 'partial/_connection'

property :rolename, String,
          name_property: true

property :superuser, [true, false]

property :createdb, [true, false]

property :createrole, [true, false]

property :inherit, [true, false]

property :login, [true, false]

property :replication, [true, false]

property :bypassrls, [true, false]

property :connection_limit, [Integer, String],
          default: -1,
          coerce: proc { |p| p.to_s }

property :unencrypted_password, String,
          sensitive: true

property :encrypted_password, String

property :valid_until, String

property :in_role, [String, Array],
          coerce: proc { |p| Array(p).join(', ') }

property :role, [String, Array],
          coerce: proc { |p| Array(p).join(', ') }

property :admin, [String, Array],
          coerce: proc { |p| Array(p).join(', ') }

property :config, Hash,
          default: {},
          coerce: proc { |p| p.transform_keys(&:to_s) }

property :sensitive, [true, false],
          default: true,
          desired_state: false

include PostgreSQL::Cookbook::SqlHelpers::Role

load_current_value do |new_resource|
  current_value_does_not_exist! unless pg_role?(new_resource.rolename)

  role_data = pg_role(new_resource.rolename)

  rolename(role_data.fetch('rolname', nil))
  superuser(role_data.fetch('rolsuper', nil))
  createdb(role_data.fetch('rolecreatedb', nil))
  createrole(role_data.fetch('rolcreaterole', nil))
  inherit(role_data.fetch('rolinherit', nil))
  login(role_data.fetch('rolcanlogin', nil))
  replication(role_data.fetch('rolreplication', nil))
  bypassrls(role_data.fetch('rolbypassrls', nil))
  connection_limit(role_data.fetch('rolconnlimit', nil))
  valid_until(role_data.fetch('rolvaluntil', nil))
  config(config_string_to_hash(role_data.fetch('rolconfig', nil)))
end

action_class do
  include PostgreSQL::Cookbook::SqlHelpers::Role
end

action :create do
  return if pg_role?(new_resource.rolename)

  converge_if_changed(
      :superuser,
      :createdb,
      :createrole,
      :inherit,
      :login,
      :replication,
      :bypassrls,
      :connection_limit,
      :unencrypted_password,
      :encrypted_password,
      :valid_until,
      :in_role,
      :role,
      :admin
    ) do
    create_role(new_resource)
  end

  converge_if_changed(:config) { set_role_configuration(new_resource) }
  converge_if_changed(:unencrypted_password, :encrypted_password) { update_role_password(new_resource) } unless pg_role_password?(new_resource.rolename)
end

action :update do
  raise Chef::Exceptions::CurrentValueDoesNotExist, "Cannot update role '#{new_resource.rolename}' as it does not exist" unless pg_role?(new_resource.rolename)

  converge_if_changed(:superuser, :createdb, :createrole, :inherit, :login, :replication, :bypassrls, :connection_limit) do
    update_role(new_resource)
  end

  converge_if_changed(:config) { set_role_configuration(new_resource) }
  converge_if_changed(:unencrypted_password, :encrypted_password) { update_role_password(new_resource) } unless pg_role_password?(new_resource.rolename)
end

action :drop do
  converge_by("Drop role #{new_resource.rolename}") { drop_role(new_resource) } if pg_role?(new_resource.rolename)
end

action :delete do
  run_action(:drop)
end

action :set_password do
  converge_if_changed(:unencrypted_password, :encrypted_password) { update_role_password(new_resource) }
end
