postgresql_install 'postgresql' do
  version node['test']['pg_ver']

  action %i(install init_server)
end

postgresql_access 'postgresql host superuser' do
  type 'host'
  database 'all'
  user 'postgres'
  address '127.0.0.1/32'
  auth_method 'md5'
end

postgresql_service 'postgresql' do
  action %i(enable start)
end

postgresql_user 'postgres' do
  unencrypted_password '12345'
  action :nothing
end

postgresql_user 'sous_chef' do
  unencrypted_password '12345'

  notifies :set_password, 'postgresql_user[postgres]', :immediately
end

postgresql_user 'sous_chef' do
  superuser true
  unencrypted_password '67890'
  config({ statement_timeout: '8min' })
  login true
  sensitive false
  action :update
end

postgresql_database 'sous_chef' do
  template 'template0'
  encoding 'utf8'
end

postgresql_access 'a sous_chef local superuser' do
  type 'host'
  database 'all'
  user 'sous_chef'
  auth_method 'md5'
  address '127.0.0.1/32'
  position 5

  notifies :restart, 'postgresql_service[postgresql]', :delayed
end

postgresql_user 'name-with-dash' do
  unencrypted_password '1234'
end

postgresql_user 'name-with-dash' do
  config({ statement_timeout: '8min' })
  sensitive false
  action :update
end

postgresql_user 'dropable-user' do
  unencrypted_password '1234'
  action [:create, :drop]
  not_if { ::File.exist?('/tmp/dropable-user.txt') }
end

file '/tmp/dropable-user.txt'

postgresql_access 'access with hostname address' do
  type 'host'
  database 'all'
  user 'hostname_user'
  auth_method 'md5'
  address 'host.domain'

  notifies :restart, 'postgresql_service[postgresql]', :delayed
end

postgresql_access 'access with hostname address username with dot' do
  type 'host'
  database 'all'
  user 'hostname.user'
  auth_method 'md5'
  address 'host.domain'

  notifies :restart, 'postgresql_service[postgresql]', :delayed
end

postgresql_access 'access with database name with an underscore' do
  type 'host'
  database 'my_database'
  user 'hostname.user'
  auth_method 'md5'
  address 'host.domain'

  notifies :restart, 'postgresql_service[postgresql]', :delayed
end

postgresql_access 'access with hostname long' do
  type 'host'
  database 'my_database'
  user 'hostname.user'
  auth_method 'md5'
  address 'a.very.long.host.domain.that.exceeds.the.max.of.24.characters'

  notifies :restart, 'postgresql_service[postgresql]', :delayed
end

postgresql_access 'access with urls as auth_options' do
  type 'host'
  database 'all'
  user 'ldap_url.user'
  address '127.0.0.1/32'
  auth_method 'ldap'
  auth_options 'ldapurl="ldap://ldap.example.net/dc=example,dc=net?uid?sub"'
end

postgresql_access 'access with several auth_options' do
  type 'host'
  database 'all'
  user 'ldap_options.user'
  address '127.0.0.1/32'
  auth_method 'ldap'
  auth_options ldapserver: 'ldap.example.net',
               ldapbasedn: '"dc=example, dc=net"',
               ldapsearchattribute: 'uid'
end

postgresql_access 'access with multiple databases' do
  type 'host'
  database 'foo,bar'
  user 'john,doe'
  address '127.0.0.1/32'
  auth_method 'md5'
end
