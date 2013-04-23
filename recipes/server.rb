#
# Cookbook Name:: postgresql
# Recipe:: server
#
# Copyright ModCloth, Inc.
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

package "postgresql92-server" do
  action :install
end

package "postgresql92-replicationtools" do
  action :install
end

package "postgresql92-datatypes" do
  action :install
end

service "postgresql92-server" do
  action :enable
  supports :enable => true, :disable => true, :restart => true
end

cookbook_file "/var/pgsql/data/pg_hba.conf" do
  source "pg_hba.conf"
  user "postgres"
  group "postgres"
  notifies :restart, "service[postgresql92-server]"
end

cookbook_file "/var/pgsql/data/pg_ident.conf" do
  source "pg_ident.conf"
  user "postgres"
  group "postgres"
  notifies :restart, "service[postgresql92-server]"
end

cookbook_file "/tmp/postgres_password.sh" do
  source "postgres_password.sh"
  mode "0755"
end

template "/var/pgsql/data/postgresql.conf" do
  source "postgresql.conf.erb"
  user "postgres"
  group "postgres"
  notifies :restart, "service[postgresql92-server]"
end

bash 'set root password for postgresql' do
  user 'root'
  code '/tmp/postgres_password.sh'
  not_if { ::File.exists?('/root/.pg_service.conf') }
end

