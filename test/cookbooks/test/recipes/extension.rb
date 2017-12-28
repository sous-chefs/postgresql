postgresql_repository 'install' do
  version '9.6'
end

postgresql_server_install 'package' do
  version '9.6'
end

postgresql_extension '' do
  database  'test_1'
  extension 'openfts'
end
