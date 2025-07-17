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
unified_mode true

use 'partial/_connection'

property :sensitive, [true, false],
          default: true,
          desired_state: false

property :rolename, String,
          name_property: true,
          description: 'The name of the new role'

property :superuser, [true, false],
          description: 'Determine whether the new role is a "superuser" who can override all access restrictions within the database'

property :createdb, [true, false],
          description: 'Define a role\'s ability to create databases'

property :createrole, [true, false],
          description: 'Determine whether a role will be permitted to create new roles (that is, execute CREATE ROLE)'

property :inherit, [true, false],
          description: 'Determine whether a role "inherits" the privileges of roles it is a member of'

property :login, [true, false],
          description: 'Determine whether a role is allowed to log in'

property :replication, [true, false],
          description: 'Determine whether a role is a replication role'

property :bypassrls, [true, false],
          description: 'Determine whether a role bypasses every row-level security (RLS) policy'

property :connection_limit, [Integer, String],
          default: -1,
          coerce: proc { |p| p.to_s },
          description: 'If role can log in, this specifies how many concurrent connections the role can make'

property :unencrypted_password, String,
          sensitive: true,
          description: 'Sets the role password via a plain text string'

property :encrypted_password, String,
          description: 'Sets the role password via a pre-encrypted string'

property :valid_until, String,
          description: 'Sets a date and time after which the role password is no longer valid'

property :in_role, [String, Array],
          coerce: proc { |p| Array(p).join(', ') },
          description: 'Lists one or more existing roles to which the new role will be immediately added as a new membe'

property :role, [String, Array],
          coerce: proc { |p| Array(p).join(', ') },
          description: 'Lists one or more existing roles which are automatically added as members of the new role'

property :admin, [String, Array],
          coerce: proc { |p| Array(p).join(', ') },
          description: 'Like ROLE, but the named roles are added to the new role WITH ADMIN OPTION, giving them the right to grant membership in this role to others'

property :config, Hash,
          default: {},
          coerce: proc { |p| p.transform_keys(&:to_s) },
          description: 'Role config values as a Hash'

include PostgreSQL::Cookbook::SqlHelpers::Role

load_current_value do |new_resource|
  current_value_does_not_exist! unless pg_role?(new_resource.rolename)

  role_data = pg_role(new_resource.rolename)

  rolename(role_data.fetch('rolname', nil))
  superuser(role_data.fetch('rolsuper', nil))
  createdb(role_data.fetch('rolcreatedb', nil))
  createrole(role_data.fetch('rolcreaterole', nil))
  inherit(role_data.fetch('rolinherit', nil))
  login(role_data.fetch('rolcanlogin', nil))
  replication(role_data.fetch('rolreplication', nil))
  bypassrls(role_data.fetch('rolbypassrls', nil))
  connection_limit(role_data.fetch('rolconnlimit', nil))
  valid_until(role_data.fetch('rolvaluntil', nil))
  config(config_string_to_hash(role_data.fetch('rolconfig', nil)))

  if new_resource.property_is_set?(:encrypted_password)
    encrypted_password(pg_role_encrypted_password(new_resource.rolename))
  end
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
