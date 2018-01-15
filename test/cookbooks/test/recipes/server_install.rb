include_recipe 'locale::default'

postgresql_repository 'install' do
  version '9.5'
end

postgresql_server_install 'package' do
  version '9.5'
end

postgresql_server_conf 'PostgreSQL Config' do
  notifies :reload, 'service[postgresql]'
end

service 'postgresql' do
  service_name lazy { platform_service_name }
  supports restart: true, status: true, reload: true
  action [:enable, :start]
end
