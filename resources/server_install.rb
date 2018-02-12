# frozen_string_literal: true
#
# Cookbook:: postgresql
# Resource:: server_install
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

property :version,           String, default: '9.6'
property :setup_repo,        [true, false], default: true
property :hba_file,          String, default: lazy { "#{conf_dir}/main/pg_hba.conf" }
property :ident_file,        String, default: lazy { "#{conf_dir}/main/pg_ident.conf" }
property :external_pid_file, String, default: lazy { "/var/run/postgresql/#{version}-main.pid" }
property :password,          [String, nil], default: 'generate'
property :port,              [String, Integer], default: 5432
property :initdb_locale,     String, default: 'UTF-8'

default_action :install

action :install do
  node.run_state['postgresql'] ||= {}
  node.run_state['postgresql']['version'] = new_resource.version

  postgresql_client_install 'Install PostgreSQL Client' do
    version new_resource.version
    setup_repo new_resource.setup_repo
  end

  package server_pkg_name
end

action :create do
  if platform_family?('rhel', 'fedora', 'amazon') && !initialized?
    db_command = rhel_init_db_command
    if db_command
      execute 'init_db' do
        command db_command
        not_if { initialized? }
      end
    else # we don't know about this platform
      log 'InitDB' do
        message 'InitDB is not supported on this distro. Skipping.'
        level :error
      end
    end
  end

  log 'Enable and start PostgreSQL service' do
    notifies :enable, postgresql_service, :immediately
    notifies :start, postgresql_service, :immediately
  end

  postgres_password = new_resource.password == 'generate' || new_resource.password.nil? ? secure_random : new_resource.password

  # Generate a ramdom password or set the a password defined with node['postgresql']['password']['postgres'].
  # The password is set or change at each run. It is good for security if you choose to set a random password and
  # allow you to change the postgres password if needed.
  bash 'generate-postgres-password' do
    user 'postgres'
    code <<-EOH
    echo "ALTER ROLE postgres ENCRYPTED PASSWORD \'#{postgres_password}\';" | psql -p #{new_resource.port}
    EOH
    not_if { ::File.exist? "#{data_dir}/recovery.conf" }
    only_if { node['postgresql']['assign_postgres_password'] }
  end
end

action_class do
  include PostgresqlCookbook::Helpers
  require 'securerandom'

  def secure_random
    r = SecureRandom.hex
    Chef::Log.debug "Generated password: #{r}"
    r
  end

  def initialized?
    return true if ::File.exist?("#{data_dir}/PG_VERSION")
    false
  end

  # determine the platform specific server package name
  def server_pkg_name
    platform_family?('debian') ? "postgresql-#{new_resource.version}" : "postgresql#{new_resource.version.delete('.')}-server"
  end

  # determine the appropriate DB init command to run based on RHEL/Fedora/Amazon release
  def rhel_init_db_command
    if platform_family?('fedora') || (platform_family?('rhel') && node['platform_version'].to_i >= 7)
      "/usr/pgsql-#{new_resource.version}/bin/postgresql#{new_resource.version.delete('.')}-setup initdb"
    elsif platform_family?('rhel') && node['platform_version'].to_i == 6
      "service postgresql-#{new_resource.version} initdb"
    elsif platform?('amazon')
      "service postgresql#{new_resource.version.delete('.')} initdb"
    end
  end
end
