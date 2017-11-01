# frozen_string_literal: true
#
# Cookbook:: postgresql
# Resource:: install
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

property :version, String, default: '9.6'
property :init_db, [true, false], default: true
property :setup_repo, [true, false], default: true

action :install do
  postgresql_client_install 'Install PostgreSQL Client' do
    version new_resource.version
    setup_repo new_resource.setup_repo
  end

  package server_pkg_name

  if platform_family?('rhel', 'fedora', 'amazon') && new_resource.init_db
    db_command = rhel_init_db_command(new_resource.version.delete('.'))
    if db_command
      execute 'init_db' do
        command db_command
      end
    else # we don't know about this platform version
      log 'InitDB' do
        message 'InitDB is not supported on this version of operating system.'
        level :error
      end
    end
  end

  service 'postgresql' do
    service_name platform_service_name
    supports restart: true, status: true, reload: true
    action [:enable, :start]
  end
end

action_class do
  # determine the platform specific server package name
  def server_pkg_name
    platform_family?('debian') ? "postgresql-#{new_resource.version}" : "postgresql#{new_resource.version.delete('.')}-server"
  end

  # determine the platform specific service name
  def platform_service_name
    platform_family?('rhel', 'amazon', 'fedora') ? "postgresql-#{new_resource.version}" : 'postgresql'
  end

  # determine the appropriate DB init command to run based on RHEL/Fedora/Amazon release
  def rhel_init_db_command(ver)
    if platform_family?('fedora') || (platform_family?('rhel') && node['platform_version'].to_i >= 7)
      "/usr/pgsql-#{new_resource.version}/bin/postgresql#{ver}-setup initdb"
    elsif platform_family?('rhel') && node['platform_version'].to_i == 6
      "service postgresql-#{new_resource.version} initdb"
    end
  end
end
