postgresql_install 'postgresql' do
  version node['test']['pg_ver']
  source :native

  action %i(install_client)
end
