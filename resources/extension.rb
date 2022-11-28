unified_mode true
use 'partial/_connection'

property :extension,        String, name_property: true
property :old_version,      String
property :version,          String

action :create do
  bash "CREATE EXTENSION #{new_resource.name}" do
    code create_extension_sql(new_resource)
    user 'postgres'
    action :run
    environment(psql_environment)
    not_if { follower? || extension_installed?(new_resource) }
  end
end

action :drop do
  bash "DROP EXTENSION #{new_resource.name}" do
    code psql_command_string(new_resource, "DROP EXTENSION IF EXISTS \"#{new_resource.extension}\"")
    user 'postgres'
    action :run
    environment(psql_environment)
    not_if { follower? }
    only_if { extension_installed?(new_resource) }
  end
end

action_class do
  include PostgreSQL::Cookbook::Helpers
end
