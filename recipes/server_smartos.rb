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
      :wal_level          => node[:postgresql][:wal_level],
      :max_wal_senders    => node[:postgresql][:max_wal_senders],
      :wal_keep_segments  => node[:postgresql][:wal_keep_segments],
      :hot_standby        => node[:postgresql][:hot_standby],
      :listen_addresses   => '*'
    )
    notifies :restart, resources(:service => "postgresql")
  end

  # set string of ips for standbys for pg_hba file
  node['postgresql']['standby_ips'] = db_standbys.map { |standby| standby['ipaddress'] }.join('/32, ')

  if node.role?(node[:postgresql][:database_master_role])
    Chef::Log.info "Current node is a master"

    # Create a replication user
    node.set_unless[:postgresql][:password][:replication_user] = secure_password

    Chef::Log.info "PGPASSWORD=#{node['postgresql']['password']['postgres']} \
    psql --username=postgres -h localhost -c \"CREATE USER replication_user WITH REPLICATION PASSWORD '#{node['postgresql']['password']['replication_user']}';\""

    execute "create replication user" do
      command "PGPASSWORD=#{node['postgresql']['password']['postgres']} \
      psql --username=postgres -h localhost -c \"CREATE USER replication_user WITH REPLICATION PASSWORD '#{node['postgresql']['password']['replication_user']}';\""
      not_if "PGPASSWORD=#{node['postgresql']['password']['postgres']} \
                              psql --username=postgres -h localhost -c \"select rolname from pg_roles where rolname='replication_user';\" | grep replication_user"
      # only_if "PGPASSWORD='postgres' echo '\connect' | PGPASSWORD=#{node['postgresql']['password']['postgres']} psql --username=postgres -h localhost"
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
      only_if { db_master['postgresql']['password']['replication_user'] }
    end

    unless node['postgresql']['replicated'] 
      directory "/var/pgsql/pgbasebackup" do
        owner "postgres"
        group "postgres"
        mode "0755"
        action :create
      end

      bash "run pg_basebackup" do
        user "root"
        cwd "/var/pgsql"
        code <<-EOH
            rm -rf /var/pgsql/pgbasebackup/*
            svcadm disable postgresql
            PGPASSWORD=#{db_master['postgresql']['password']['replication_user']} pg_basebackup -v -U replication_user -h #{db_master['ipaddress'].to_s} -D /var/pgsql/pgbasebackup
            cp -r /var/pgsql/pgbasebackup/* /var/pgsql/data91/
            chown -R postgres:postgres /var/pgsql/data91/
            svcadm enable postgresql
        EOH
        only_if { db_master['postgresql']['password']['replication_user'] }
      end

      node['postgresql']['password']['postgres'] = db_master['postgresql']['password']['postgres']

      ruby_block "confirm replication" do
        node['postgresql']['replicated'] = true
        only_if "tail -n 1 /var/log/postgresql91.log | grep 'ready to accept read only connections'"
      end
    end
  end
else
  # write out normal settings non-replication
  template "#{node[:postgresql][:dir]}/postgresql.conf" do
    source "smartos.postgresql.conf.erb"
    owner "postgres"
    group "postgres"
    mode 0600
    # variables(
    #       :listen_addresses => node['postgresql']['listen_addresses']
    #     )
    variables(
      :wal_level => 'hot_standby',
      :max_wal_senders => 8,
      :wal_keep_segments => 8,
      :hot_standby => true,
      :listen_addresses => '*'
    )
    notifies :restart, resources(:service => "postgresql")
  end
end
