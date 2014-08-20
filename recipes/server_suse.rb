#
# Cookbook Name:: postgresql
# Recipe:: server_suse
#
# Author:: Alexander Simonov (<alex@simonov.me>)
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

::Chef::Recipe.send(:include, Opscode::PostgresqlHelpers)
data_dir = node['postgresql']['dir']

# Create a group and user like the package will.
# Otherwise the templates fail.
create_rpm_user_and_group
create_data_dir
install_server_packages

execute "sed -i 's|POSTGRES_DATADIR=\".*\"|POSTGRES_DATADIR=\"#{data_dir}\"|' /etc/sysconfig/postgresql"

setup_command = "su - postgres -c \"/usr/bin/initdb --locale=#{node['postgresql']['initdb_locale']} --auth='ident' #{data_dir}\""
execute setup_command do
  not_if { ::FileTest.exist?(File.join(data_dir, "PG_VERSION")) }
end