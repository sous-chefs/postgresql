#
# Cookbook:: postgresql
# Recipe:: server_pgdg
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# instructions from https://wiki.postgresql.org/wiki/YUM_Installation

include_recipe 'postgresql::client'

# svc_name = node['postgresql']['server']['service_name']
# initdb_locale = node['postgresql']['initdb_locale']
#
# shortver = node['postgresql']['version'].split('.').join
#
# package node['postgresql']['server']['packages']
#
# # If using PGDG, add symlinks so that downstream commands all work
# [
#   "postgresql#{shortver}-setup",
#   "postgresql#{shortver}-check-db-dir",
# ].each do |cmd|
#   link "/usr/bin/#{cmd}" do
#     to "/usr/pgsql-#{node['postgresql']['version']}/bin/#{cmd}"
#   end
# end
#
# if Chef::Platform::ServiceHelpers.service_resource_providers.include?(:systemd)
#   execute "#{node['postgresql']['setup_script']} initdb #{svc_name}" do
#     not_if { node['platform_family'] == 'debian' }
#     not_if { ::File.exist?("#{node['postgresql']['config']['data_directory']}/PG_VERSION") }
#   end
# else
#   execute "/sbin/service #{svc_name} initdb" do
#     not_if { node['platform_family'] == 'debian' }
#     not_if { ::File.exist?("#{node['postgresql']['config']['data_directory']}/PG_VERSION") }
#   end
# end
#
# service 'postgresql' do
#   service_name svc_name
#   # supports restart: true, status: true, reload: true
#   action [:enable, :start]
# end


node.normal['postgresql']['dir'] = value_for_platform_family({
  ['rhel', 'fedora', 'suse'] => "/var/lib/pgsql/#{node['postgresql']['version']}/data",
  ['debian'] => "/var/lib/postgresql/#{node['postgresql']['version']}/main"
})

postgresql_pgdg_server_install 'default' do
  version node['postgresql']['version']
  packages node['postgresql']['server']['packages']
  data_directory node['postgresql']['config']['data_directory']
end

postgresql_config 'default' do
  config_directory node['postgresql']['dir']
end

# include_recipe 'postgresql::server_conf'
