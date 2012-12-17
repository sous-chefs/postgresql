include_recipe 'apt'

apt_repository 'pitti-postgresql-ppa' do
  uri 'http://ppa.launchpad.net/pitti/postgresql/ubuntu'
  distribution node['lsb']['codename']
  components %w(main)
  keyserver 'keyserver.ubuntu.com'
  key '8683D8A2'
  action :add
end
