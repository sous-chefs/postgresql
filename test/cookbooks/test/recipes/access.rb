postgresql_install 'postgresql' do
  version node['test']['pg_ver']

  action %i(install init_server)
end

postgresql_access 'local all postgresql trust' do
  type 'local'
  database 'all'
  user 'postgres'
  auth_method 'trust'
  comment 'Testing local postgres trust'
end

postgresql_access 'local all all trust' do
  type 'local'
  database 'all'
  user 'all'
  auth_method 'trust'
end

postgresql_access 'postgresql host superuser' do
  type 'host'
  database 'all'
  user 'postgres'
  address '127.0.0.1/32'
  auth_method 'md5'
end

postgresql_service 'postgresql' do
  action %i(enable start)
end

postgresql_user 'postgres' do
  unencrypted_password '12345'
  action :nothing
end

postgresql_user 'sous_chef' do
  unencrypted_password '12345'

  notifies :set_password, 'postgresql_user[postgres]', :immediately
end

postgresql_user 'sous_chef' do
  superuser true
  unencrypted_password '67890'
  config({ statement_timeout: '8min' })
  login true
  sensitive false
  action :update
end

postgresql_database 'sous_chef'

postgresql_access 'a sous_chef local superuser' do
  type 'host'
  database 'all'
  user 'sous_chef'
  auth_method 'md5'
  address '127.0.0.1/32'

  notifies :restart, 'postgresql_service[postgresql]', :delayed
end

postgresql_user 'name-with-dash' do
  unencrypted_password '1234'
end

postgresql_user 'name-with-dash' do
  config({ statement_timeout: '8min' })
  sensitive false
  action :update
end

postgresql_user 'dropable-user' do
  unencrypted_password '1234'
  action [:create, :drop]
  not_if { ::File.exist?('/tmp/dropable-user.txt') }
end

file '/tmp/dropable-user.txt'
