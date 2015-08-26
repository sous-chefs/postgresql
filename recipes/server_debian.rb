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

include_recipe "postgresql::client"

node['postgresql']['server']['packages'].each do |pg_pack|

  package pg_pack

end


two_digit_version = node['postgresql']['version'].split('.')[0..1].join('.')

# Create the service, enable it, stop it
service "postgresql" do
  service_name node['postgresql']['server']['service_name']
  supports :restart => true, :status => true, :reload => true
  action [:enable,:stop]
end

execute "Drop the default cluster" do
	command "pg_dropcluster #{two_digit_version} main"
	only_if { `pg_lsclusters | awk -v ver=#{two_digit_version} -v name=main 'NR>1 { if(ver==$1 && name==$2) { print $6 } }'`.chomp.eql?('/var/lib/postgresql/9.1/main') }
	action :run
end

include_recipe "postgresql::server_conf"

# Create the cluster
execute 'Set locale and Create cluster' do
  command "export LC_ALL=C; /usr/bin/pg_createcluster --datadir='#{node['postgresql']['config']['data_directory']}' #{two_digit_version} main"
  action :run
  not_if { ::File.directory?(node['postgresql']['config']['data_directory'] + '/PG_VERSION') }
end

# Start the server again
service "postgresql" do
  service_name node['postgresql']['server']['service_name']
  action [:start]
end

