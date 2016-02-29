#
# Cookbook Name:: postgresql
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

include_recipe 'postgresql::config_version'
include_recipe "postgresql::client"

node['postgresql']['server']['packages'].each do |pg_pack|

  package pg_pack

end

if ( node[:platform_version].to_f == 12.04 || node[:platform_version].to_f == 14.04 ) && node[:postgresql][:upstart]
  # Install the upstart script for 12.04 and 14.04

  template "/etc/init/postgresql.conf" do
    source 'postgresql-upstart.conf.erb'
  end

  initd_script = '/etc/init.d/postgresql'

  file initd_script do
    action :delete
    not_if { File.symlink? initd_script }
  end

  link initd_script do
    to '/lib/init/upstart-job'
  end

  execute 'update-rc.d -f postgresql remove' do
    only_if 'ls /etc/rc*.d/*postgresql'
  end
end


service "postgresql" do
  if ( node[:platform_version].to_f == 12.04 || node[:platform_version].to_f == 14.04 ) && node[:postgresql][:upstart]
    provider Chef::Provider::Service::Upstart
  end
  service_name node['postgresql']['server']['service_name']
  supports :restart => true, :status => true, :reload => true
  action [:enable, :start]
end

