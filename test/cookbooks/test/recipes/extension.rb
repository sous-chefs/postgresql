postgresql_repository 'install'

# Dokken images don't have all locales available so this is a workaround
encoding = value_for_platform(
  [:debian, :ubuntu, :fedora] => { default: 'C.UTF-8' },
  centos: { default: 'en_GB.utf8' },
  default: 'en_US.utf8'
)

postgresql_server_install 'package' do
  password '12345'
  action [:install, :create]
  initdb_locale encoding
  version '9.6'
end

postgresql_database 'test_1' do
  locale encoding
end

if platform_family?('rhel')
  package 'postgresql96-contrib'
else
  package 'postgresql-contrib'
end

postgresql_extension 'plpgsql' do
  database 'test_1'
end

postgresql_extension '\"uuid-ossp\"' do
  database 'test_1'
end
