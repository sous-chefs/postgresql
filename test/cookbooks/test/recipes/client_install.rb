# This resource should install the postgresql client
postgresql_client_install 'postgresql client' do
  version node['test']['pg_ver']
end
