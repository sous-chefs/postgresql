#
# Cookbook Name:: postgresql
# Recipe:: server
#
# Author:: Joshua Timberman (<joshua@opscode.com>)
# Author:: Lamont Granquist (<lamont@opscode.com>)
# Copyright 2009-2011, Opscode, Inc.
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

::Chef::Recipe.send(:include, Opscode::PostgresqlHelpers)

version = node['postgresql']['version']
data_dir = node['postgresql']['dir']

# Create a group and user like the package will.
# Otherwise the templates fail.

group "postgres" do
  gid 26
end

user "postgres" do
  shell "/bin/bash"
  comment "PostgreSQL Server"
  home "/var/lib/pgsql"
  gid "postgres"
  system true
  uid 26
  supports :manage_home => false
end

directory data_dir do
  owner "postgres"
  group "postgres"
  recursive true
  action :create
end

node['postgresql']['server']['packages'].each do |pg_pack|

  package pg_pack

end

if systemd?
  unless data_dir == "/var/lib/pgsql/#{version}/data"
    template "/etc/systemd/system/postgresql-#{version}.service" do
      source "postgresql.service.erb"
      mode "0644"
    end
  end
else
  template "/etc/sysconfig/pgsql/#{node['postgresql']['server']['service_name']}" do
    source "pgsql.sysconfig.erb"
    mode "0644"
    notifies :restart, "service[postgresql]", :delayed
  end
end

unless platform_family?("suse")
  setup_command = if systemd?
                    systemd_initdb_cmd
                  else
                    sysinit_initdb_cmd
                  end
  execute setup_command do
    not_if { ::FileTest.exist?(File.join(node['postgresql']['dir'], "PG_VERSION")) }
  end
end

service "postgresql" do
  service_name node['postgresql']['server']['service_name']
  supports :restart => true, :status => true, :reload => true
  action [:enable, :start]
end
