# Dokken images don't have all locales available so this is a workaround
locale = value_for_platform(
  [:debian, :ubuntu, :fedora, :oracle, :amazon] => { default: 'C.UTF-8' },
  centos: { default: node['platform_version'].to_i < 8 ? 'en_GB.utf-8' : 'C.UTF-8' },
  default: 'en_US'
)

postgresql_server_install 'package' do
  password '12345'
  action [:install, :create]
  initdb_locale locale
  initdb_encoding 'UTF-8'
  version node['test']['pg_ver']
end

postgresql_database 'test_1' do
  locale locale
end

if platform_family?('debian')
  package 'postgresql-contrib'
else
  package "postgresql#{node['test']['pg_ver']}-contrib"
end

postgresql_extension 'plpgsql' do
  database 'test_1'
end

postgresql_extension 'uuid-ossp' do
  database 'test_1'
end
