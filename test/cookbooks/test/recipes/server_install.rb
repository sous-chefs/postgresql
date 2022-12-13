postgresql_install 'postgresql' do
  version node['test']['pg_ver']
  action %i(install init_server)
end

postgresql_config 'postgresql-server' do
  version '15'

  server_config({
    'max_connections' => 110,
    'shared_buffers' => '128MB',
    'dynamic_shared_memory_type' => 'posix',
    'max_wal_size' => '1GB',
    'min_wal_size' => '80MB',
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
