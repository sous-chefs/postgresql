postgresql_server_install 'postgresql' do
  password '12345'
  port 5432
  setup_repo true
  action [:install, :create]
end

user 'shef'

postgresql_ident 'postgresl mapping' do
  mapname 'testmap'
  system_user 'postgres'
  pg_user 'postgres'
  notifies :reload, 'service[postgresql]'
end

postgresql_ident 'shef mapping' do
  mapname 'testmap'
  system_user 'shef'
  pg_user 'sous_chef'
  notifies :reload, 'service[postgresql]'
end

postgresql_access 'postgresql host superuser' do
  access_type 'host'
  access_db 'all'
  access_user 'postgres'
  access_addr '127.0.0.1/32'
  access_method 'md5'
  notifies :reload, 'service[postgresql]'
end

postgresql_access 'shef mapping' do
  access_type 'local'
  access_db 'all'
  access_user 'all'
  access_method 'peer map=testmap'
  cookbook 'test'
  notifies :reload, 'service[postgresql]'
end

postgresql_user 'sous_chef' do
  superuser true
  password '67890'
  sensitive false
end

service 'postgresql' do
  extend PostgresqlCookbook::Helpers
  service_name lazy { platform_service_name }
  supports restart: true, status: true, reload: true
  action :nothing
end
