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

normal['postgresql']['config']['stand_by'] = true

include_recipe 'postgres::server'

if node['postgresql'].attribute?('recovery')
  template "#{node['postgresql']['config']['data_directory']}/recovery.conf"
    source "recovery.conf.erb"
    owner "postgres"
    group "postgres"
    mode 0600
    variables(
      node['postgresql']['recovery']    
    )
    notifies :restart, 'service[postgresql]', :delayed
  end
end