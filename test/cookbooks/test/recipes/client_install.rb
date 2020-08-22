# This resource should install the postgresql client
postgresql_client_install 'postgresql client' do
  version node['pg_ver']
end
