postgresql_repository 'install'

postgresql_server_install 'package' do
  action [:install, :create]
end

postgresql_database 'test_1'

package 'postgresql-contrib'

postgresql_extension 'adminpack' do
  database 'test_1'
end
