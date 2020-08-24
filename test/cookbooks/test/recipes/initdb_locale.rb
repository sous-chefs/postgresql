postgresql_server_install 'Install' do
  version node['test']['pg_ver']
  initdb_locale node['platform_version'].to_i < 8 ? 'en_GB.utf8' : 'C.UTF-8'
  action [:install, :create]
end
