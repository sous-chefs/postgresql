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

node.default[:postgresql][:ssl] = "true"

node.default[:postgresql][:listen_addresses] = node.ipaddress

# package "postgresql91-adminpack"
package "postgresql91-server"

service "postgresql" do
  supports :restart => true, :status => true, :reload => true
  action [:enable, :start]
end

db_master   = search("node", "role:#{node[:postgresql][:database_master_role]} AND chef_environment:#{node.chef_environment}").first
db_standbys = search("node", "role:#{node[:postgresql][:database_standby_role]} AND chef_environment:#{node.chef_environment}") || []

# If we have a standby (streaming replication)
if db_standbys.size > 0
  Chef::Log.info("Found standbys, configuring for replication")
  Chef::Log.info("DB_MASTER FOUND = #{db_master} IPADDRESS = #{db_master['ipaddress']}")

  template "#{node[:postgresql][:dir]}/postgresql.conf" do
    source "smartos.postgresql.conf.erb"
    owner "postgres"
    group "postgres"
    mode 0600
    variables(
      :wal_level => 'hot_standby',
      :max_wal_senders => db_standbys.size,
      :hot_standby => true,
      :listen_addresses => '*'
    )
    notifies :restart, resources(:service => "postgresql")
  end

  if node.role?(node[:postgresql][:database_master_role])
    # Create a replication user
    node.set_unless[:postgresql][:password][:replication_user] = secure_password

    Chef::Log.info "PGPASSWORD=#{node['postgresql']['password']['postgres']} \
    psql --username=postgres -h localhost -c \"CREATE USER replication_user WITH REPLICATION PASSWORD '#{node['postgresql']['password']['replication_user']}';\""

    execute "create replication user" do
      command "PGPASSWORD=#{node['postgresql']['password']['postgres']} \
      psql --username=postgres -h localhost -c \"CREATE USER replication_user WITH REPLICATION PASSWORD '#{node['postgresql']['password']['replication_user']}';\""
    end

    template "#{node[:postgresql][:dir]}/pg_hba.conf" do
      source "pg_hba.conf.erb"
      owner "postgres"
      group "postgres"
      mode 0600
      variables(:standbys => db_standbys)
      notifies :reload, resources(:service => "postgresql")
    end
  end

  if node.role?(node[:postgresql][:database_standby_role])
    Chef::Log.info "Current node is a standby"
    # write out slave settings
    template "#{node[:postgresql][:dir]}/recovery.conf" do
      source "smartos.postgresql.recovery.conf.erb"
      owner "postgres"
      group "postgres"
      mode 0600
      variables(
        :db_master_ip => db_master['ipaddress'].to_s,
        :replication_user => 'replication_user',
        :replication_password => db_master['postgresql']['password']['replication_user']
      )
    end

    unless node['postgresql']['replicated']
      directory "/modpkg/pgbasebackup" do
        owner "root"
        group "root"
        mode "0755"
        action :create
      end

      service "postgresql" do
        action :stop
      end

      execute "run pg_basebackup" do
        command "pg_basebackup -v -U replication_user -h #{db_master['ipaddress'].to_s} -D /modpkg/pgbasebackup/"
        notifies :start, resources(:service => "postgresql")
      end

      node['postgresql']['replicated'] = true
    end
  end
else
  # write out normal settings non-replication
  template "#{node[:postgresql][:dir]}/pg_hba.conf" do
    source "pg_hba.conf.erb"
    owner "postgres"
    group "postgres"
    mode 0600
    notifies :reload, resources(:service => "postgresql")
  end

  template "#{node[:postgresql][:dir]}/postgresql.conf" do
    source "smartos.postgresql.conf.erb"
    owner "postgres"
    group "postgres"
    mode 0600
    variables(
      :listen_addresses => node['postgresql']['listen_addresses']
    )
    notifies :restart, resources(:service => "postgresql")
  end
end
