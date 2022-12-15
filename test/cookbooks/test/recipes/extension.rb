# Dokken images don't have all locales available so this is a workaround
locale = value_for_platform(
  %i(debian ubuntu fedora oracle amazon almalinux rocky) => { default: 'C.UTF-8' },
  centos: { default: node['platform_version'].to_i < 8 ? 'en_US.utf-8' : 'C.UTF-8' },
  default: 'en_US'
)

postgresql_install 'postgresql' do
  version node['test']['pg_ver']
  initdb_locale locale
  initdb_encoding 'UTF-8'

  action %i(install init_server)
end

postgresql_service 'postgresql' do
  action %i(enable start)
end

postgresql_user 'postgres' do
  unencrypted_password '12345'
  action :nothing
end

postgresql_database 'test_1' do
  locale locale if node['test']['pg_ver'].to_i >= 13
  notifies :set_password, 'postgresql_user[postgres]', :immediately
end

if platform_family?('debian')
  package 'postgresql-contrib'
else
  package "postgresql#{node['test']['pg_ver'].delete('.')}-contrib"
end

postgresql_extension 'plpgsql' do
  dbname 'test_1'
end

postgresql_extension 'uuid-ossp' do
  dbname 'test_1'
end
