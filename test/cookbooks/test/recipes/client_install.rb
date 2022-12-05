postgresql_install 'postgresql' do
  version node['test']['pg_ver']

  action %i(install_client)
end
