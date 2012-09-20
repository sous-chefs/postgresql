#
# Cookbook Name:: postgresql
# Recipe:: ruby
#
# Author:: Joshua Timberman (<joshua@opscode.com>)
# Copyright 2012 Opscode, Inc.
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

execute "apt-get update" do
  ignore_failure true
  action :nothing
end.run_action(:run) if node['platform_family'] == "debian"

node.set['build_essential']['compiletime'] = true
include_recipe "build-essential"
include_recipe "postgresql::client"

def pkg_devel_installed?
  pg_devel_pkg = node['postgresql']['client']['packages'].select { |pkg| pkg =~ /devel/ }.first

  if platform? "debian", "ubuntu"
    pkg_cmd = "dpkg -l"
  else
    pkg_cmd = "rpm -qa"
  end

  pg_devel_status = Chef::ShellOut.new("#{pkg_cmd} #{pg_devel_pkg}").run_command.stdout
  pg_devel_installed = ! pg_devel_status.empty?
end

link "/usr/bin/pg_config" do
  to "/usr/pgsql-#{node['postgresql']['version']}/bin/pg_config"
  unless pg_devel_installed?
    action :nothing
    subscribes :create, resources("package[#{pg_devel_pkg}]"), :immediately
  else
    action :create
  end
end

chef_gem "pg" do
  if ::File.exists? "/usr/bin/pg_config"
    action :install
  else
    action :nothing
    subscribes :install, resources("link[/usr/bin/pg_config]"), :immediately
  end
end
