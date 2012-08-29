#
# Cookbook Name:: postgresql
# Recipe:: server
#
# Author:: Joshua Timberman (<joshua@opscode.com>)
# Author:: Lamont Granquist (<lamont@opscode.com>)#
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

node.default[:postgresql][:ssl] = "true"

node.default[:postgresql][:listen_addresses] = node.ipaddress

# package "postgresql91-adminpack"
package "postgresql91-server"

service "postgresql" do
  supports :restart => true, :status => true, :reload => true
  action [:enable, :start]
end

# if replication
# write out special template with replication
#else

db_master = search("node", "role:#{node[:postgresql][:database_master_role]} AND chef_environment:#{node.chef_environment}").first
if db_master
  Chef::Log.info("DB_MASTER FOUND = #{db_master} IPADDRESS = #{db_master['ipaddress']}")
  if node[:postgresql][:database_master]
    # write out master settings
    template "#{node[:postgresql][:dir]}/postgresql.conf" do
      source "smartos.postgresql.conf.erb"
      owner "postgres"
      group "postgres"
      mode 0600
      variables(
        :master => true
      )
      notifies :restart, resources(:service => "postgresql")
    end
  else
    # write out slave settings
    template "#{node[:postgresql][:dir]}/recovery.conf" do
      source "smartos.postgresql.recovery.conf.erb"
      owner "postgres"
      group "postgres"
      mode 0600
      variables(
        :db_master_ip => db_master['ipadress'].to_s
      )
    end
    
    template "#{node[:postgresql][:dir]}/postgresql.conf" do
      source "smartos.postgresql.conf.erb"
      owner "postgres"
      group "postgres"
      mode 0600
      variables(
        :slave => true
      )
      notifies :restart, resources(:service => "postgresql")
    end
    
    # rsync -av --exclude pg_xlog --exclude postgresql.conf data/* 192.168.0.2:/var/lib/postgresql/data/
    
  end
else
  # write out normal settings non-replication
  template "#{node[:postgresql][:dir]}/postgresql.conf" do
    source "smartos.postgresql.conf.erb"
    owner "postgres"
    group "postgres"
    mode 0600
    notifies :restart, resources(:service => "postgresql")
  end
end
