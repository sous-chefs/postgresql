#
# Cookbook Name:: postgresql
# Recipe:: server
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

change_notify = node['postgresql']['server']['config_change_notify']

# There are some configuration items which depend on correctly evaluating the intended version being installed
if node['platform_family'] == 'debian'

  node.set['postgresql']['config']['hba_file'] = "/etc/postgresql/#{node['postgresql']['version']}/#{node['postgresql']['cluster_name']}/pg_hba.conf"
  node.set['postgresql']['config']['ident_file'] = "/etc/postgresql/#{node['postgresql']['version']}/#{node['postgresql']['cluster_name']}/pg_ident.conf"
  node.set['postgresql']['config']['external_pid_file'] = "/var/run/postgresql/#{node['postgresql']['version']}-#{node['postgresql']['cluster_name']}.pid"

  if node['postgresql']['version'].to_f < 9.3
    node.set['postgresql']['config']['unix_socket_directory'] = '/var/run/postgresql'
  else
    node.set['postgresql']['config']['unix_socket_directories'] = '/var/run/postgresql'
  end

  if node['postgresql']['config']['ssl']
    node.set['postgresql']['config']['ssl_cert_file'] = '/etc/ssl/certs/ssl-cert-snakeoil.pem' if node['postgresql']['version'].to_f >= 9.2
    node.set['postgresql']['config']['ssl_key_file'] = '/etc/ssl/private/ssl-cert-snakeoil.key' if node['postgresql']['version'].to_f >= 9.2
  end

  node.set['postgresql']['config']['max_fsm_pages'] = 153600 if node['postgresql']['version'].to_f < 8.4

end

if node['postgresql']['server']['init_package'] == 'upstart'
  # Install the upstart script for 12.04 and 14.04

  template "/etc/init/#{node['postgresql']['server']['service_name']}.conf" do
    source 'postgresql-upstart.conf.erb'
  end

  initd_script = "/etc/init.d/#{node['postgresql']['server']['service_name']}"

  file initd_script do
    action :delete
    not_if { File.symlink? initd_script }
  end

  link initd_script do
    to '/lib/init/upstart-job'
  end

  execute 'update-rc.d -f postgresql remove' do
    only_if 'ls /etc/rc*.d/*postgresql'
  end
end

directory node['postgresql']['dir'] do
  owner 'postgres'
  group 'postgres'
  recursive true
  action :create
end

template "#{node['postgresql']['dir']}/postgresql.conf" do
  source "postgresql.conf.erb"
  owner "postgres"
  group "postgres"
  mode 0600
  if platform?("ubuntu") && node['platform_version'].to_f < 15.04
    notifies :start, 'service[postgresql]', :immediately
  else
    notifies change_notify, 'service[postgresql]', :immediately
  end
end

template "#{node['postgresql']['dir']}/pg_hba.conf" do
  source "pg_hba.conf.erb"
  owner "postgres"
  group "postgres"
  mode 00600
  notifies change_notify, 'service[postgresql]', :immediately
end
