#
# Cookbook Name:: postgresql
# Recipe:: server_streaming_slave
#
# Author:: Jeff Harvey-Smith (<jeff@clearstorydata.com>)
# Copyright 2014, clearstorydata
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

# ensure that the amster host (or IP) is set.
# or else to what are we a slave?
missing_attrs = %w{
  master_host
}.select do |attr|
  node['postgresql']['streaming'][attr].nil?
end.map { |attr| "node['postgresql']['streaming']['#{attr}']" }

if !missing_attrs.empty?
  Chef::Application.fatal!([
      "You must set #{missing_attrs.join(', ')} in chef-solo mode.",
    ].join(' '))
end

if node['postgresql']['version'].to_f < 9.3
  Chef::Log.fatal!("Streaming replication requires postgresql 9.3 or greater and
    you have configured #{node['postgresql']['version']}.  Bail!")
end

if node['postgresql']['streaming'].attribute?('slave') && node['postgresql']['streaming']['slave'].attribute?('config')
  node['postgresql']['streaming']['slave']['config'].each do |k,v|
    node.default['postgresql']['config'][k] = v
  end
end

include_recipe 'postgresql::server'

# setup the slave
service "postgresql" do
  Chef::Log.info("About to shut down postgresql")
  action :stop
end

execute "remove-psql-slave-datadir" do
  command "rm -rf #{node['postgresql']['config']['data_directory']}"
  not_if do ! FileTest.directory?( node['postgresql']['config']['data_directory'] ) end
end

execute "create-psql-slave-datadir" do
  user    "postgres"
  command "pg_basebackup -X s -D #{node['postgresql']['config']['data_directory']} -U postgres -h #{node['postgresql']['streaming']['master_host']} -R"
end

service "postgresql" do
  action :start
end