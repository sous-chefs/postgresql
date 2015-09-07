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

pre_installed = ::File.directory?('/etc/postgresql/' + node['postgresql']['version'] + '/main')

node['postgresql']['server']['packages'].each do |pg_pack|

  package pg_pack

end

include_recipe "postgresql::server_conf"

service "postgresql" do
  service_name node['postgresql']['server']['service_name']
  supports :restart => true, :status => true, :reload => true
  action [:enable, :start]
end

# this is required as postgresql-9.3 (and later?) package creates a 'main' cluster for us, giving us
# no opportunity to set the locale
execute 'Drop main cluster' do
  command "/usr/bin/pg_dropcluster --stop #{node['postgresql']['version']} main"
  action :run
  not_if pre_installed
end

initdb_locale = node['postgresql']['initdb_locale']

default_cmd = "export LC_ALL=C; /usr/bin/pg_createcluster --start #{node['postgresql']['version']} main"
locale_cmd = "/usr/bin/pg_createcluster --locale=#{initdb_locale} --start #{node['postgresql']['version']} main"

execute 'Set locale and Create cluster' do
  command initdb_locale.nil? ? default_cmd : locale_cmd
  action :run
  not_if { ::File.directory?('/etc/postgresql/' + node['postgresql']['version'] + '/main') }
end
