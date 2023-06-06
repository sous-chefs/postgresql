postgresql_install 'postgresql' do
  source :os
  action %i(install init_server)
end

postgresql_config 'postgresql-server' do
  server_config({
    'max_connections' => 110,
    'shared_buffers' => '128MB',
    'log_destination' => 'stderr',
    'logging_collector' => true,
    'log_directory' => 'log',
    'log_filename' => 'postgresql-%a.log',
    'log_rotation_age' => '1d',
    'log_rotation_size' => 0,
    'log_truncate_on_rotation' => true,
    'log_line_prefix' => '%m [%p]',
    'log_timezone' => 'Etc/UTC',
    'datestyle' => 'iso, mdy',
    'timezone' => 'Etc/UTC',
    'lc_messages' => 'C',
    'lc_monetary' => 'C',
    'lc_numeric' => 'C',
    'lc_time' => 'C',
    'default_text_search_config' => 'pg_catalog.english',
  })

  notifies :restart, 'postgresql_service[postgresql]', :delayed
  action :create
end

postgresql_service 'postgresql' do
  action %i(enable start)
end

postgresql_access 'postgresql host superuser' do
  type 'host'
  database 'all'
  user 'postgres'
  address '127.0.0.1/32'
  auth_method 'md5'
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

postgresql_database 'sous_chef' do
  template 'template0'
  encoding 'utf8'
end

postgresql_database 'test1' do
  action :create
end

postgresql_access 'a sous_chef local superuser' do
  type 'host'
  database 'all'
  user 'sous_chef'
  auth_method 'md5'
  address '127.0.0.1/32'

  notifies :restart, 'postgresql_service[postgresql]', :delayed
end

postgresql_ident 'postgresl mapping' do
  map_name 'testmap1'
  system_username 'postgres'
  database_username 'postgres'
  comment 'Postgresql 1 test mapping'

  notifies :reload, 'postgresql_service[postgresql]', :delayed
end
