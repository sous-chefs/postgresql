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

property :hba_file, String, default: "/etc/postgresql/#{version}/main/pg_hba.conf"
property :ident_file, String, default: "/etc/postgresql/#{version}/main/pg_ident.conf"
property :external_pid_file, String, default: "/var/run/postgresql/#{version}-main.pid"


action :install do
  postgresql_client_install 'Install PostgreSQL Client' do
    version new_resource.version
    setup_repo new_resource.setup_repo
  end

  case node['platform_family']
  when 'rhel', 'fedora','amazon'
    ver = new_resource.version.delete('.')
    package ["postgresql#{ver}-server"]

    if new_resource.init_db && !initialized

      case node['platform_version'].to_i
      when 7
        execute 'init_db' do
          command "/usr/pgsql-#{new_resource.version}/bin/postgresql#{ver}-setup initdb"
        end
      when 6, 2017
        execute 'init_db' do
          command "service postgresql-#{new_resource.version} initdb"
        end
      else
        log 'InitDB' do
          message "InitDB is not supported on this version of operating system. Trying: service postgresql-#{new_resource.version} initdb"
          level :error
        end
      end

      file "#{data_dir}/initialized.txt" do
        content 'Database initialized'
        mode '0744'
      end

    end

  when 'debian'
    package "postgresql-#{new_resource.version}"
  end

  service 'postgresql' do
    case node['platform_family']
    when 'rhel', 'amazon'
      service_name "postgresql-#{new_resource.version}"
    when 'debian'
      service_name 'postgresql'
    end
    supports restart: true, status: true, reload: true
    action [:enable, :start]
  end
end

action_class do
  include 'PostgresqlCookbook::Helpers'

  def initialized
    true if ::File.exist?("#{data_dir}/initialized.txt")
  end
end
