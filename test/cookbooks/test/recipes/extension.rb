postgresql_repository 'install'

postgresql_server_install 'package' do
  action [:install, :create]
  locale 'en_US.utf8'
end

postgresql_database 'test_1' do
  locale 'en_US.utf8'
end

package 'postgresql-contrib'

postgresql_extension 'adminpack' do
  source_directory '/usr/share/pgsql/extension/'
  database 'test_1'
end
