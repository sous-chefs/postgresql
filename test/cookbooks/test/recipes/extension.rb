postgresql_repository 'install'

postgresql_server_install 'package' do
  password '12345'
  action [:install, :create]
  initdb_locale 'en_US.utf8'
end

postgresql_database 'test_1' do
  locale 'en_US.utf8'
end

package 'postgresql-contrib'

postgresql_extension 'adminpack' do
  database 'test_1'
end
