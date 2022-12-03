unified_mode true
use 'partial/_connection'

# Override the database property from the partial
property :database,
         String,
         name_property: true

property :template, String, default: 'template1'
property :encoding, String
property :locale,   String
property :owner,    String

action_class do
  include PostgreSQL::Cookbook::Helpers
end

# action :create do
#   createdb = 'createdb'
#   createdb << " -E #{new_resource.encoding}" if new_resource.encoding
#   createdb << " -l #{new_resource.locale}" if new_resource.locale
#   createdb << " -T #{new_resource.template}" unless new_resource.template.empty?
#   createdb << " -O #{new_resource.owner}" if new_resource.owner
#   createdb << " -U #{new_resource.user}" if new_resource.user
#   createdb << " -h #{new_resource.host}" if new_resource.host
#   createdb << " -p #{new_resource.port}" if new_resource.port
#   createdb << " #{new_resource.database}"

#   bash "Create Database #{new_resource.database}" do
#     code createdb
#     user new_resource.user
#     not_if { follower? }
#     not_if { database_exists?(new_resource) }
#   end
# end

# action :drop do
#   converge_by "Drop PostgreSQL Database #{new_resource.database}" do
#     dropdb = 'dropdb'
#     dropdb << " -U #{new_resource.user}" if new_resource.user
#     dropdb << " --host #{new_resource.host}" if new_resource.host
#     dropdb << " --port #{new_resource.port}" if new_resource.port
#     dropdb << " #{new_resource.database}"

#     bash "drop postgresql database #{new_resource.database})" do
#       user 'postgres'
#       code dropdb
#       not_if { follower? }
#       only_if { database_exists?(new_resource) }
#     end
#   end
# end
