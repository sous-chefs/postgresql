postgresql_install 'postgresql' do
  version node['test']['pg_ver']

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

user 'shef'
user 'shef2'

postgresql_ident 'postgresl mapping' do
  map_name 'testmap1'
  system_username 'postgres'
  database_username 'postgres'
  comment 'Postgresql 1 test mapping'

  notifies :reload, 'postgresql_service[postgresql]', :delayed
end

postgresql_ident 'shef mapping' do
  map_name 'testmap2'
  system_username 'shef'
  database_username 'sous_chef'

  notifies :reload, 'postgresql_service[postgresql]', :delayed
end

postgresql_ident 'shef2 mapping' do
  map_name 'testmap2'
  system_username 'shef2'
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

postgresql_ident 'map with very long name' do
  map_name 'this_is_a_very_long_map_name_that_should_be_handled_correctly_by_the_postgresql_ident_resource'
  system_username 'shef'
  database_username 'sous_chef'

  notifies :reload, 'postgresql_service[postgresql]', :delayed
end

postgresql_access 'postgresql host superuser' do
  type 'host'
  database 'all'
  user 'postgres'
  address '127.0.0.1/32'
  auth_method 'scram-sha-256'

  notifies :reload, 'postgresql_service[postgresql]', :delayed
end

postgresql_access 'shef mapping' do
  type 'local'
  database 'all'
  user 'sous_chef'
  auth_method 'peer'
  auth_options 'map=testmap2'
  cookbook 'test'

  notifies :reload, 'postgresql_service[postgresql]', :delayed
end

postgresql_user 'sous_chef' do
  superuser true
  login true
  password '67890'
  sensitive false

  notifies :set_password, 'postgresql_user[postgres]', :delayed
end

postgresql_user 'sous_chef' do
  superuser false
  connection_limit 5
  action :update
end

postgresql_user 'postgres' do
  unencrypted_password '12345'
  action :nothing
end

postgresql_database 'test1'

postgresql_database 'test2' do
  action :delete
end

postgresql_extension 'plpgsql'
