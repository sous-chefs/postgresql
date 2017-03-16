include_recipe 'zypper'

# SLES 12 only has 9.4, so add unofficial builds from opensuse build service
zypper_repo 'server_database_postgresql' do
  uri 'http://download.opensuse.org/repositories/server:/database:/postgresql/SLE_12_SP1/'
  key 'http://download.opensuse.org/repositories/server:/database:/postgresql/SLE_12_SP1/repodata/repomd.xml.key'
  autorefresh true
end
