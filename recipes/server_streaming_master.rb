#
# Cookbook Name:: postgresql
# Recipe:: server_streaming_master
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

if node['postgresql']['version'].to_f < 9.3
  Chef::Log.fatal!("Streaming replication requires postgresql 9.3 or greater and
    you have configured #{node['postgresql']['version']}.  Bail.")
end

node['postgresql']['streaming']['master']['config'].each do |k,v|
  node.default['postgresql']['config'][k] = v
end

node.default['postgresql']['pg_hba'] =
  node['postgresql']['streaming']['master']['pg_hba']

include_recipe 'postgresql::server'

if node['postgresql'].attribute? 'shared_archive'
  directory node['postgresql']['shared_archive'] do
    owner "postgres"
    group "postgres"
    mode 00755
    action :create
  end
end