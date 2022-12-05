postgresql_install 'postgresql' do
  version node['test']['pg_ver']

  action %i(install init_server)
end

user 'shef'

postgresql_ident 'postgresl mapping' do
  map_name 'testmap1'
  system_username 'postgres'
  database_username 'postgres'

  notifies :reload, 'postgresql_service[postgresql]', :delayed
end

postgresql_ident 'shef mapping' do
  map_name 'testmap2'
  system_username 'shef'
  database_username 'sous_chef'

  notifies :reload, 'postgresql_service[postgresql]', :delayed
end

postgresql_ident 'shef remove mapping' do
  map_name 'testmap3'
  system_username 'shef_remove'
  database_username 'sous_chef'

  notifies :reload, 'postgresql_service[postgresql]', :delayed
  action :delete
end

postgresql_access 'postgresql host superuser' do
  type 'host'
  database 'all'
  user 'postgres'
  address '127.0.0.1/32'
  auth_method 'md5'

  notifies :reload, 'postgresql_service[postgresql]', :delayed
end

postgresql_access 'shef mapping' do
  type 'local'
  database 'all'
  user 'all'
  auth_method 'peer'
  auth_options 'map=testmap'
  cookbook 'test'

  notifies :reload, 'postgresql_service[postgresql]', :delayed
end

postgresql_service 'postgresql' do
  action %i(enable start)
end

postgresql_user 'sous_chef' do
  superuser true
  password '67890'
  sensitive false
end

postgresql_user 'sous_chef' do
  superuser false
  connection_limit 5
  action :update
end

postgresql_database 'test1' do
  # action :delete
end

postgresql_database 'test2' do
  action :delete
end

postgresql_extension 'plpgsql'
