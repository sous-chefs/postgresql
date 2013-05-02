#
# Cookbook Name:: postgresql
# Recipe:: ppa_pgdg_postgresql
#
# Author:: Jason Rutherford (<jason@jrutherford.com>)
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

#
# This recipe will add the PostgreSQL Global Development Group (PGDG) 
# maintained APT repository of PostgreSQL packages for Debian and Ubuntu.
# This makes available several versions of Postgresql available for
# APT installation.
#
# For more information see: https://wiki.postgresql.org/wiki/Apt
#

#
# USAGE
# =====
#
# Just set node['postgresql']['enable_pgdg_ppa'] to true and you'll be able
# to install any version included the repository like 8.4, 9.1, 9.2. 
#
# Vagrantfile example:
#
#  ...
#  chef.json = {
#      :postgresql => {
#        :enable_postgresql_ppa => true,
#				 :version => '8.4',
#        :password => {
#					  :postgres => 'apppass'
#        	}
#				}
#  }
#  ...

include_recipe 'apt'

apt_repository 'pgdg' do
  uri 'http://apt.postgresql.org/pub/repos/apt/'
  distribution "#{node['lsb']['codename']}-pgdg"
  components %w(main)
  keyserver 'keyserver.ubuntu.com'
  key 'ACCC4CF8'
  action :add
end
