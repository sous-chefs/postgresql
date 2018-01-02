postgresql_repository 'install' do
  version '9.5'
end

postgresql_server_install 'package' do
  version '9.5'
end

postgresql_user 'testuser' do
  superuser true
  login     true
  password  'mysecret'
end

postgresql_database 'testdb' do
  owner 'testuser'
end
