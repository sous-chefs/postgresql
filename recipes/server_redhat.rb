# frozen_string_literal: true
#
# Cookbook:: postgresql
# Recipe:: server
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

include_recipe 'postgresql::client'

svc_name = node['postgresql']['server']['service_name']
initdb_locale = node['postgresql']['initdb_locale']

shortver = node['postgresql']['version'].split('.').join

# Create a group and user like the package will.
# Otherwise the templates fail.

group 'postgres' do
  gid node['postgresql']['gid']
end

user 'postgres' do
  shell '/bin/bash'
  comment 'PostgreSQL Server'
  home '/var/lib/pgsql'
  gid 'postgres'
  system true
  uid node['postgresql']['uid']
  manage_home false
end

directory node['postgresql']['config']['data_directory'] do
  owner 'postgres'
  group 'postgres'
  recursive true
  action :create
  mode '0700'
end

package node['postgresql']['server']['packages']

# If using PGDG, add symlinks so that downstream commands all work
if node['postgresql']['enable_pgdg_yum'] == true || node['postgresql']['use_pgdg_packages'] == true
  [
    "postgresql#{shortver}-setup",
    "postgresql#{shortver}-check-db-dir",
  ].each do |cmd|
    link "/usr/bin/#{cmd}" do
      to "/usr/pgsql-#{node['postgresql']['version']}/bin/#{cmd}"
    end
  end
end

# The systemd unit file does not support 'initdb' or 'upgrade' actions.
# Use the postgresql-setup script instead.

unless node['postgresql']['server']['init_package'] == 'systemd'

  directory '/etc/sysconfig/pgsql' do
    mode '0644'
    recursive true
    action :create
  end

  template "/etc/sysconfig/pgsql/#{svc_name}" do
    source 'pgsql.sysconfig.erb'
    mode '0644'
    notifies :restart, 'service[postgresql]', :delayed
  end

end

if node['postgresql']['server']['init_package'] == 'systemd'

  if node['platform_family'] == 'rhel'

    template_path = if node['postgresql']['use_pgdg_packages']
                      "/etc/systemd/system/postgresql-#{node['postgresql']['version']}.service"
                    else
                      '/etc/systemd/system/postgresql.service'
                    end

    template template_path do
      source 'postgresql.service.erb'
      owner 'root'
      group 'root'
      mode '0644'
      notifies :run, 'execute[systemctl-reload]', :immediately
      notifies :reload, 'service[postgresql]', :delayed
    end
    execute 'systemctl-reload' do
      command 'systemctl daemon-reload'
      action :nothing
    end
  end

  case node['platform_family']
  when 'suse'
    execute "initdb -d #{node['postgresql']['dir']}" do
      user 'postgres'
      not_if { ::File.exist?("#{node['postgresql']['config']['data_directory']}/PG_VERSION") }
    end
  else
    execute "#{node['postgresql']['setup_script']} initdb #{svc_name}" do
      not_if { ::File.exist?("#{node['postgresql']['config']['data_directory']}/PG_VERSION") }
    end
  end

elsif !platform_family?('suse') && node['postgresql']['version'].to_f <= 9.3

  execute "/sbin/service #{svc_name} initdb #{initdb_locale}" do
    not_if { ::File.exist?("#{node['postgresql']['config']['data_directory']}/PG_VERSION") }
  end

else

  execute "/sbin/service #{svc_name} initdb" do
    not_if { ::File.exist?("#{node['postgresql']['config']['data_directory']}/PG_VERSION") }
  end

end

service 'postgresql' do
  service_name svc_name
  supports restart: true, status: true, reload: true
  action [:enable, :start]
end

include_recipe 'postgresql::server_conf'
