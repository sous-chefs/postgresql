include_recipe 'locale::default'

postgresql_repository 'install' do
  version '9.5'
end

postgresql_server_install 'package' do
  version '9.5'
end

postgresql_server_conf 'PostgreSQL Config' do
  version '9.5'
  notifies :reload, 'service[postgresql]'
end

postgresql_access 'testuser' do
  access_type 'host'
  access_db 'testdb'
  access_user 'testuser'
  access_addr '127.0.0.1/32'
  access_method 'md5'
end

service 'postgresql' do
  service_name lazy { platform_service_name }
  supports restart: true, status: true, reload: true
  action [:enable, :start]
end
