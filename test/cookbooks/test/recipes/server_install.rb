include_recipe 'locale::default'

postgresql_repository 'install' do
  version '9.5'
end

postgresql_server_install 'package' do
  version '9.5'
end

pg_config = {
  'default_statistics_target' => '100',
  'maintenance_work_mem'      => "512MB",
  'effective_cache_size'      => "2GB",
  'work_mem'                  => "128MB",
  'wal_buffers'               => "1536kB",
  'shared_buffers'            => "512MB",
  'max_connections'           => "10"
}

postgresql_server_conf 'PostgreSQL Config' do
  version '9.5'
  config pg_config
  notification :reload
end
