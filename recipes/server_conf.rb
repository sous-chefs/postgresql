# frozen_string_literal: true
#
# Cookbook:: postgresql
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

  node.normal['postgresql']['config']['hba_file'] = "/etc/postgresql/#{node['postgresql']['version']}/main/pg_hba.conf"
  node.normal['postgresql']['config']['ident_file'] = "/etc/postgresql/#{node['postgresql']['version']}/main/pg_ident.conf"
  node.normal['postgresql']['config']['external_pid_file'] = "/var/run/postgresql/#{node['postgresql']['version']}-main.pid"

  if node['postgresql']['version'].to_f < 9.3
    node.normal['postgresql']['config']['unix_socket_directory'] = '/var/run/postgresql'
  elsif !node['postgresql']['config'].key?('unix_socket_directories')
    node.normal['postgresql']['config']['unix_socket_directories'] = '/var/run/postgresql'
  end

  if node['postgresql']['config']['ssl']
    node.normal['postgresql']['config']['ssl_cert_file'] = '/etc/ssl/certs/ssl-cert-snakeoil.pem' if node['postgresql']['version'].to_f >= 9.2
    node.normal['postgresql']['config']['ssl_key_file'] = '/etc/ssl/private/ssl-cert-snakeoil.key' if node['postgresql']['version'].to_f >= 9.2
  end

end

template "#{node['postgresql']['dir']}/postgresql.conf" do # ~FC037
  source 'postgresql.conf.erb'
  owner 'postgres'
  group 'postgres'
  mode '0600'
  notifies change_notify, 'service[postgresql]', :immediately
end

if !node['postgresql']['pg_hba'].empty?
  Chef::Log.warn 'Configuring access via attributes is **DEPRECATED**. Please use the new postgresql_access resource. See README for migration information'
  node['postgresql']['pg_hba'].each do |access|
    # Generate a unique string for the resource to avoid cloning
    access_name = "#{access[:type]}_#{access[:db]}_#{access[:user]}_#{access[:method]}"
    postgresql_access access_name do
      access_type access[:type]
      access_db access[:db]
      access_user access[:user]
      access_addr access[:addr]
      access_method access[:method]
      notification change_notify
    end
  end
end
