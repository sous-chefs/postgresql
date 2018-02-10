# frozen_string_literal: false
#
# Cookbook:: postgresql
# Library:: resource_helpers
# Author:: Dan Webb (<dan.webb@damacus.io)
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

module PostgresqlCookbook
  module Helpers
    def data_dir(version = node.run_state['postgresql']['version'])
      case node['platform_family']
      when 'rhel', 'fedora', 'amazon'
        "/var/lib/pgsql/#{version}/data"
      when 'debian'
        "/var/lib/postgresql/#{version}/main"
      end
    end

    def conf_dir(version = node.run_state['postgresql']['version'])
      case node['platform_family']
      when 'rhel', 'fedora', 'amazon'
        "/var/lib/pgsql/#{version}/data"
      when 'debian'
        "/etc/postgresql/#{version}/main"
      end
    end

    # determine the platform specific service name
    def platform_service_name(version = node.run_state['postgresql']['version'])
      if %w(rhel amazon fedora).include?(node['platform_family'])
        "postgresql-#{version}"
      else
        'postgresql'
      end
    end

    def postgresql_service
      resources(service: 'postgresql')
    rescue Chef::Exceptions::ResourceNotFound
      service 'postgresql' do
        service_name lazy { platform_service_name }
        supports restart: true, status: true, reload: true
        action :nothing
      end
    end

    def psql_command_string(database, query)
      "psql -d #{database} <<< '\\set ON_ERROR_STOP on\n#{query};'"
    end

    # XXX: Remove me after removing this method elsewhere
    def psql(database, query)
      psql_command_string(database, query)
    end

    def slave?
      ::File.exist? "#{data_dir}/recovery.conf"
    end
  end
end

Chef::Recipe.include(PostgresqlCookbook::Helpers)
Chef::Resource.include(PostgresqlCookbook::Helpers)
