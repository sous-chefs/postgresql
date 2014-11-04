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

case node['platform_family']
when "rhel", "fedora", "suse"
  pg_id = 26
  pg_home = '/var/lib/pgsql'
when "debian"
  pg_home = '/var/lib/postgresql'
end

group "postgres" do
  gid pg_id
end

user "postgres" do
  shell "/bin/bash"
  comment "PostgreSQL Server"
  home pg_home
  gid "postgres"
  system true
  uid pg_id
  supports :manage_home => false
end

directory node['postgresql']['dir'] do
  owner "postgres"
  group "postgres"
  recursive true
  action :create
end

directory "/var/lib/postgresql/#{node['postgresql']['version']}" do
  owner "postgres"
  group "postgres"
  recursive true
  mode 00700
  action :create
end
