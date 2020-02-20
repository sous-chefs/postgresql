postgresql_repository 'install'

postgresql_server_install 'package' do
  action [:install, :create]
end

# Using this to generate a service resource to control
find_resource(:service, 'postgresql') do
  extend PostgresqlCookbook::Helpers
  service_name(lazy { platform_service_name })
  supports restart: true, status: true, reload: true
  action [:enable, :start]
end

postgresql_server_conf 'PostgreSQL Config' do
  notifies :reload, 'service[postgresql]'
end
