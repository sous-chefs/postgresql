include_recipe 'locale::default'

postgresql_repository 'install' do
  version '9.5'
end

postgresql_server_install 'package' do
  version '9.5'
end

postgresql_server_conf 'PostgreSQL Config' do
  version '9.5'
  notification :reload
end
