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

if node['postgresql']['version'].to_f > 9 && node['platform_version'].to_f >= 6.0 && node['platform_version'].to_f < 7.0
apt_repository "debian-backports" do
    uri "http://backports.debian.org/debian-backports"
    components ["main"]
    distribution "squeeze-backports"
    action :add
  end

  apt_repository "pgapt.debian.net" do
    uri "http://apt.postgresql.org/pub/repos/apt/"
    components ["9.0","9.1","9.2","9.3"]
    distribution "squeeze-pgdg"
    action :add
  end

  include_recipe 'apt'
  
  package 'libpq5' do
    options '-t squeeze-backports'
    action :install
  end

  package 'postgresql-common' do
    options '-t squeeze-backports'
    action :install
  end
  
  package "postgresql-#{node['postgresql']['version']}"
else
  node['postgresql']['server']['packages'].each do |pg_pack|
    package pg_pack
  end
end

service "postgresql" do
  service_name node['postgresql']['server']['service_name']
  supports :restart => true, :status => true, :reload => true
  action [:enable, :start]
end
