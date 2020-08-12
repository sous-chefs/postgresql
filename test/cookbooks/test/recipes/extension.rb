postgresql_repository 'install'
# # Dokken images don't have all locales available so this is a workaround
locale = case node['platform_family']
         when /^(debian|ubuntu|fedora)$/
           'C.UTF-8'
         when 'rhel'
           if node['hostname'].match?(/oracle/)
             'C.UTF-8'
           else
             node['platform_version'].to_i < 8 ? 'en_GB.UTF-8' : 'C.UTF-8'
           end
         else
           'en_US.UTF-8'
         end

postgresql_server_install 'package' do
  password '12345'
  action [:install, :create]
  initdb_locale locale
  initdb_encoding 'UTF-8'
  version '12'
end

postgresql_database 'test_1' do
  locale locale
end

if platform_family?('debian')
  package 'postgresql-contrib'
else
  package 'postgresql12-contrib'
end

postgresql_extension 'plpgsql' do
  database 'test_1'
end

postgresql_extension '\"uuid-ossp\"' do
  database 'test_1'
end
