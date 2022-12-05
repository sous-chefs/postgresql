postgresql_install 'postgresql' do
  action %i(install init_server)
end

postgresql_service 'postgresql' do
  action %i(enable start)
end

postgresql_access 'postgresql all all trust' do
  type 'local'
  database 'all'
  user 'all'
  auth_method 'trust'

  notifies :restart, 'postgresql_service[postgresql]', :delayed
end

postgresql_access 'postgresql host superuser' do
  type 'host'
  database 'all'
  user 'postgres'
  address '127.0.0.1/32'
  auth_method 'md5'

  notifies :restart, 'postgresql_service[postgresql]', :delayed
end

postgresql_user 'sous_chef' do
  superuser true
  password '67890'
  sensitive false
end

postgresql_user 'sous_chef' do
  config({ statement_timeout: '8min' })
  sensitive false
  action :update
end

postgresql_access 'a sous_chef local superuser' do
  type 'host'
  database 'all'
  user 'sous_chef'
  auth_method 'md5'
  address '127.0.0.1/32'

  notifies :restart, 'postgresql_service[postgresql]', :delayed
end

postgresql_user 'name-with-dash' do
  password '1234'
end

postgresql_user 'name-with-dash' do
  config({ statement_timeout: '8min' })
  sensitive false
  action :update
end

postgresql_user 'dropable-user' do
  password '1234'
  action [:create, :drop]
end
