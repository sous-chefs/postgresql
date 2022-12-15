postgresql_install 'postgresql' do
  version node['test']['pg_ver']
  initdb_locale node['platform_version'].to_i < 8 ? 'en_US.utf8' : 'C.UTF-8'

  action %i(install init_server)
end

postgresql_access 'local all all peer delete' do
  type 'local'
  database 'all'
  user 'all'
  auth_method 'peer'

  action :delete
end

postgresql_service 'postgresql' do
  action %i(enable start)
end

postgresql_user 'postgres' do
  unencrypted_password '12345'
  action :set_password
  not_if { ::File.exist?('/tmp/postgres-user.txt') }
end

file '/tmp/postgres-user.txt'
