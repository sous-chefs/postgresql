# unified_mode true

# include PostgreSQL::Cookbook::Helpers

# property :version,           [String, Integer], default: '12'
# property :setup_repo,        [true, false], default: true
# property :hba_file,          String, default: lazy { "#{conf_dir}/main/pg_hba.conf" }
# property :ident_file,        String, default: lazy { "#{conf_dir}/main/pg_ident.conf" }
# property :external_pid_file, String, default: lazy { "/var/run/postgresql/#{version}-main.pid" }
# property :password,          [String, nil], default: 'generate', sensitive: true # Set to nil if we do not want to set a password
# property :port,              Integer, default: 5432
# property :initdb_locale,     String
# property :initdb_encoding,   String

# # Connection preferences
# property :user,     String, default: 'postgres'
# property :database, String
# property :host,     [String, nil]
# property :psqlrc,   [true, false], default: true

# action_class do
#   include PostgreSQL::Cookbook::Helpers
# end

# # First install the postgresql-common package
# if platform_family?('debian')
#   package 'postgresql-common'

#   initdb_options = ''
#   initdb_options << "--locale #{new_resource.initdb_locale}" if new_resource.initdb_locale
#   initdb_options << " -E #{new_resource.initdb_encoding}" if new_resource.initdb_encoding

#   template '/etc/postgresql-common/createcluster.conf' do
#     source 'createcluster.conf.erb'
#     cookbook 'postgresql'
#     variables(
#       initdb_options: initdb_options
#     )
#   end
# end
# end

# action :create do
#   execute 'init_db' do
#     command rhel_init_db_command(new_resource)
#     user new_resource.user
#     not_if { initialized? }
#     only_if { platform_family?('rhel', 'fedora', 'amazon') }
#   end

#   # We previously used find_resource here.
#   # But that required the user to do the same in their recipe.
#   # This also seemed to never trigger notifications, therefore requiring a log resource
#   # to notify the enable/start on the service, which always fires (Check v7.0 tag for more)
#   # service 'postgresql' do
#   #   service_name platform_service_name
#   #   supports restart: true, status: true, reload: true, enable: true
#   #   action [:enable, :start]
#   # end

#   # # Generate a random password or set it as per new_resource.password.
#   # bash 'generate-postgres-password' do
#   #   user 'postgres'
#   #   code alter_role_sql(new_resource)
#   #   not_if { user_has_password?(new_resource) }
#   #   not_if { new_resource.password.nil? }
#   # end
# end
