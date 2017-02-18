# frozen_string_literal: true
apt_repository 'apt.postgresql.org' do
  uri 'http://apt.postgresql.org/pub/repos/apt'
  distribution "#{node['postgresql']['pgdg']['release_apt_codename']}-pgdg"
  components ['main', node['postgresql']['version']]
  key 'https://www.postgresql.org/media/keys/ACCC4CF8.asc'
  action :add
end
