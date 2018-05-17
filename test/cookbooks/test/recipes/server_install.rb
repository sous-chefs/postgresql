postgresql_repository 'install' do
  version '9.6'
end

postgresql_server_install 'package' do
  version '9.6'
end

# Using this to generate a service resource to control
find_resource(:service, 'postgresql') do
  service_name lazy { PostgresqlCookbook::Helpers.platform_service_name }
  supports restart: true, status: true, reload: true
  action :nothing
end

postgresql_server_conf 'PostgreSQL Config' do
  version '9.6'
  notifies :reload, 'service[postgresql]'
end
