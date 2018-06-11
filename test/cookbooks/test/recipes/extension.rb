postgresql_repository 'install'

postgresql_server_install 'package'

postgresql_database 'test_1'

postgresql_extension 'openfts' do
  database 'test_1'
end
