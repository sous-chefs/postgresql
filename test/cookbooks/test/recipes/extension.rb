postgresql_repository 'install'

postgresql_server_install 'package' do
  password '12345'
  action [:install, :create]
  initdb_locale 'C.utf8'
  version '9.6'
end

postgresql_database 'test_1' do
  locale 'C.utf8'
end

if platform_family?('rhel')
  package 'postgresql96-contrib'
else
  package 'postgresql-contrib'
end

postgresql_extension 'plpgsql' do
  database 'test_1'
end
