# frozen_string_literal: true
apt_repository 'apt.postgresql.org' do
  uri node['postgresql']['pgdg']['repo_apt_url']
  distribution "#{node['postgresql']['pgdg']['release_apt_codename']}-pgdg"
  components ['main', node['postgresql']['version']]
  key node['postgresql']['pgdg']['repo_apt_key']
  action :add
end
