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

property :packages, Array, default: %w(node['postgresql']['server']['packages']) # TODO
property :service_name, String, default: lazy {  node['postgresql']['server']['service_name'] }
property :version, String, default: '10'
property :minor_version, String, default: '10-1'
property :locale, String, default: lazy { node['postgresql']['initdb_locale'] }
property :init_db, [true, false], default: true

action :install do
  postgresql_client_install 'client' do
    version "#{new_resource.version}"
    minor_version "#{new_resource.minor_version}"
  end

  case node['platform_family']
  when 'rhel'
    package ["postgresql#{new_resource.version}-server"]

    if new_resource.init_db
      case node['platform_version'].to_i
      when 7
        execute 'init_db' do
          command "/usr/pgsql-#{new_resource.version}/bin/postgresql-#{new_resource.version}-setup initdb"
        end
      when 6
        execute 'init_db' do
          command "service postgresql-#{new_resource.version} initdb"
        end
      else
        log 'InitDB' do
          message 'InitDB is not supported on this version of operating system.'
          level :error
        end
      end
    end
  when 'debian'
    package "postgresql-#{new_resource.version}"
  end


  service "postgresql" do
    service_name node['platform_family'] == 'rhel' ? "postgresql-#{new_resource.version}" : "postgresql"
    supports restart: true, status: true, reload: true
    action [:enable, :start]
  end

end
