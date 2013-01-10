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

::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

include_recipe "postgresql::client"

# randomly generate postgres password, unless using solo - see README
if Chef::Config[:solo]
  missing_attrs = %w{
    postgres
  }.select do |attr|
    node['postgresql']['password'][attr].nil?
  end.map { |attr| "node['postgresql']['password']['#{attr}']" }

  if !missing_attrs.empty?
    Chef::Application.fatal!([
        "You must set #{missing_attrs.join(', ')} in chef-solo mode.",
        "For more information, see https://github.com/opscode-cookbooks/postgresql#chef-solo-note"
      ].join(' '))
  end
else
  node.set_unless['postgresql']['password']['postgres'] = secure_password
  node.save
end

# Include the right "family" recipe for installing the server
# since they do things slightly differently.
case node['platform_family']
when "rhel", "fedora", "suse"
  include_recipe "postgresql::server_redhat"
when "debian"
  include_recipe "postgresql::server_debian"
end

template "#{node['postgresql']['dir']}/postgresql.conf" do
  source "postgresql.conf.erb"
  owner "postgres"
  group "postgres"
  mode 0600
  notifies :restart, 'service[postgresql]', :immediately
  variables({
    :data_directory => node['postgresql']['config']['data_directory'],
    :hba_file => node['postgresql']['config']['hba_file'],
    :ident_file => node['postgresql']['config']['ident_file'],
    :external_pid_file => node['postgresql']['config']['external_pid_file'],
    :listen_addresses => node['postgresql']['config']['listen_addresses'],
    :port => node['postgresql']['config']['port'],
    :max_connections => node['postgresql']['config']['max_connections'],
    :unix_socket_directory => node['postgresql']['config']['unix_socket_directory'],
    :ssl => node['postgresql']['config']['ssl'],
    :shared_buffers => node['postgresql']['config']['shared_buffers'],
    :max_fsm_pages => node['postgresql']['config']['max_fsm_pages'],
    :logging_collector => node['postgresql']['config']['logging_collector'],
    :log_directory => node['postgresql']['config']['log_directory'],
    :log_filename => node['postgresql']['config']['log_filename'],
    :log_truncate_on_rotation => node['postgresql']['config']['log_truncate_on_rotation'],
    :log_rotation_age => node['postgresql']['config']['log_rotation_age'],
    :log_rotation_size => node['postgresql']['config']['log_rotation_size'],
    :log_line_prefix => node['postgresql']['config']['log_line_prefix'],
    :datestyle => node['postgresql']['config']['datestyle'],
    :lc_messages => node['postgresql']['config']['lc_messages'],
    :lc_monetary => node['postgresql']['config']['lc_monetary'],
    :lc_numeric => node['postgresql']['config']['lc_numeric'],
    :lc_time => node['postgresql']['config']['lc_time'],
    :default_text_search_config => node['postgresql']['config']['default_text_search_config']
  })
end

template "#{node['postgresql']['dir']}/pg_hba.conf" do
  source "pg_hba.conf.erb"
  owner "postgres"
  group "postgres"
  mode 00600
  notifies :reload, 'service[postgresql]', :immediately
end

# Default PostgreSQL install has 'ident' checking on unix user 'postgres'
# and 'md5' password checking with connections from 'localhost'. This script
# runs as user 'postgres', so we can execute the 'role' and 'database' resources
# as 'root' later on, passing the below credentials in the PG client.
bash "assign-postgres-password" do
  user 'postgres'
  code <<-EOH
echo "ALTER ROLE postgres ENCRYPTED PASSWORD '#{node['postgresql']['password']['postgres']}';" | psql
  EOH
  not_if "echo '\connect' | PGPASSWORD=#{node['postgresql']['password']['postgres']} psql --username=postgres --no-password -h localhost"
  action :run
end
