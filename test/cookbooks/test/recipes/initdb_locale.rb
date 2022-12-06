postgresql_install 'postgresql' do
  version node['test']['pg_ver']
  initdb_locale node['platform_version'].to_i < 8 ? 'en_GB.utf8' : 'C.UTF-8'

  action %i(install init_server)
end

postgresql_service 'postgresql' do
  action %i(enable start)
end
