postgresql_server_install 'postgresql' do
  version '9.6'
  password '12345'
  port 5432
  setup_repo true
end

postgresql_access 'postgresql host superuser' do
  access_type 'host'
  access_db 'all'
  access_user 'postgres'
  access_addr '127.0.0.1/32'
  access_method 'md5'
end
