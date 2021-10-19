unified_mode true
use 'partial/_connection'

property :create_user,        String, name_property: true
property :superuser,          [true, false], default: false
property :createdb,           [true, false], default: false
property :createrole,         [true, false], default: false
property :inherit,            [true, false], default: true
property :replication,        [true, false], default: false
property :login,              [true, false], default: true
property :password,           String, sensitive: true
property :encrypted_password, String
property :valid_until,        String
property :attributes,         Hash, default: {}
property :sensitive,          [true, false], default: true

action :create do
  Chef::Log.warn('You cannot use "attributes" property with create action.') unless new_resource.attributes.empty?

  execute "create postgresql user #{new_resource.create_user}" do
    user 'postgres'
    command create_user_sql(new_resource)
    sensitive new_resource.sensitive || !!new_resource.password
    environment(psql_environment)
    not_if { follower? || user_exists?(new_resource) }
  end
end

action :update do
  if new_resource.attributes.empty?
    execute "update postgresql user #{new_resource.create_user}" do
      user 'postgres'
      command update_user_sql(new_resource)
      environment(psql_environment)
      sensitive new_resource.sensitive
      not_if { follower? }
      only_if { user_exists?(new_resource) }
    end
  else
    new_resource.attributes.each do |attr, value|
      v = if value.is_a?(TrueClass) || value.is_a?(FalseClass)
            value.to_s
          else
            "'#{value}'"
          end

      execute "Update postgresql user #{new_resource.create_user} to set #{attr}" do
        user 'postgres'
        command update_user_with_attributes_sql(new_resource, attr, v)
        environment(psql_environment)
        sensitive new_resource.sensitive
        not_if { follower? || attribute_is_set?(new_resource.create_user, attr, v) }
        only_if { user_exists?(new_resource) }
      end
    end
  end
end

action :drop do
  execute "drop postgresql user #{new_resource.create_user}" do
    user 'postgres'
    command drop_user_sql(new_resource)
    environment(psql_environment)
    sensitive new_resource.sensitive
    not_if { follower? }
    only_if { user_exists?(new_resource) }
  end
end

action_class do
  include PostgresqlCookbook::Helpers
end
