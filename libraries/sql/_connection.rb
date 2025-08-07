#
# Cookbook:: postgresql
# Library:: sql/_connection
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

require_relative '../_utils'
require_relative '../helpers'

module PostgreSQL
  module Cookbook
    module SqlHelpers
      module Connection
        private

        include PostgreSQL::Cookbook::Utils
        include PostgreSQL::Cookbook::Helpers

        def postgresql_devel_pkg_name(version: installed_postgresql_major_version, source: installed_postgresql_package_source)
          case node['platform_family']
          when 'rhel'
            source.eql?(:repo) ? "postgresql#{version}-devel" : 'postgresql-devel'
          when 'debian'
            'libpq-dev'
          when 'amazon'
            'libpq-devel'
          end
        end

        def postgresql_devel_path(suffix = nil, version: installed_postgresql_major_version)
          path = case node['platform_family']
                 when 'rhel', 'amazon'
                   "/usr/pgsql-#{version}"
                 when 'debian'
                   '/usr/include/postgresql'
                 else
                   raise "Unsupported platform family #{node['platform_family']}"
                 end

          path = ::File.join(path, suffix) unless nil_or_empty?(suffix)

          path
        end

        def pg_gem_build_options
          case node['platform_family']
          when 'rhel', 'amazon'
            "--platform ruby -- --with-pg-include=#{postgresql_devel_path('include')} --with-pg-lib=#{postgresql_devel_path('lib')}"
          when 'debian'
            "--platform ruby -- --with-pg-include=#{postgresql_devel_path} --with-pg-lib=#{postgresql_devel_path}"
          else
            raise "Unsupported platform family #{node['platform_family']}"
          end
        end

        def install_pg_gem
          return if gem_installed?('pg')

          libpq_package_name = case installed_postgresql_package_source
                               when :os
                                 'libpq'
                               when :repo
                                 'libpq5'
                               end

          if platform_family?('rhel')
            case node['platform_version'].to_i
            when 7
              declare_resource(:package, 'epel-release') { compile_time(true) }
              declare_resource(:package, 'centos-release-scl') { compile_time(true) }
            when 8
              declare_resource(:package, libpq_package_name) { compile_time(true) }
              declare_resource(:package, 'perl-IPC-Run') do
                compile_time(true)
                if platform?('oracle')
                  options ['--enablerepo=ol8_codeready_builder']
                else
                  options('--enablerepo=powertools')
                end
              end
            when 9
              declare_resource(:package, libpq_package_name) { compile_time(true) }
              declare_resource(:package, 'perl-IPC-Run') do
                compile_time(true)
                if platform?('oracle')
                  options ['--enablerepo=ol9_codeready_builder']
                else
                  options('--enablerepo=crb')
                end
              end
            end
          end

          declare_resource(:build_essential, 'Build Essential') { compile_time(true) }
          declare_resource(:package, postgresql_devel_pkg_name) { compile_time(true) }

          build_options = pg_gem_build_options
          declare_resource(:chef_gem, 'pg') do
            options build_options
            version '~> 1.4'
            compile_time true
          end
        end

        def pg_connection_params
          scope = respond_to?(:new_resource) ? new_resource : self

          return scope.connection_string unless nil_or_empty?(scope.connection_string)

          %i(host port options dbname user password).map do |p|
            next unless scope.respond_to?(p)

            [ p, scope.send(p) ]
          end.to_h.compact
        end

        def pg_client
          install_pg_gem unless gem_installed?('pg')

          raise 'pg Gem Missing' unless gem_installed?('pg')

          require 'pg' unless defined?(::PG)

          connection_params = pg_connection_params
          Chef::Log.debug("Got params: [#{connection_params.class}] #{connection_params}")

          host = connection_params.fetch(:host, nil) || :local_socket
          dbname = connection_params.fetch(:dbname, 'postgres')
          client = node.run_state.dig('postgresql_pg_connection', host, dbname)

          if client.is_a?(::PG::Connection)
            Chef::Log.info("Returning pre-existing client for #{host}/#{dbname}")
            return client
          end

          Chef::Log.info("Creating client for #{host}/#{dbname}")

          # The Chef Infra Client runs as user `root`. In local connnection
          # mode we have to connect as local user `postgres` to the socket.
          # This is needed to pass peer authentication for the database
          # superuser.
          if host == :local_socket
            Process::UID.eid = Process::UID.from_name('postgres')
          end

          begin
            client = ::PG::Connection.new(**connection_params)
          ensure
            if host == :local_socket
              # Switch back to elevated privileges
              Process::UID.switch
            end
          end

          client.type_map_for_queries = PG::BasicTypeMapForQueries.new(client)

          node.run_state['postgresql_pg_connection'] ||= {}
          node.run_state['postgresql_pg_connection'][host] ||= {}
          node.run_state['postgresql_pg_connection'][host][dbname] = client

          node.run_state['postgresql_pg_connection'][host][dbname]
        end

        def execute_sql(query, max_one_result: false)
          Chef::Log.debug("Executing query: #{query}")
          result = pg_client.exec(query).to_a

          Chef::Log.debug("Got result: #{result}")
          return if result.empty?

          raise "Expected a single result, got #{result.count}" unless result.one? || !max_one_result

          result
        end

        def execute_sql_params(query, params, max_one_result: false)
          Chef::Log.debug("Executing query: #{query} with params: #{params}")
          result = pg_client.exec_params(query, params).to_a

          Chef::Log.debug("Got result: #{result}")
          return if result.empty?

          raise "Expected a single result, got #{result.count}" unless result.one? || !max_one_result

          result
        end
      end
    end
  end
end
