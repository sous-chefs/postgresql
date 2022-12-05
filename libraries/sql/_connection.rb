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

module PostgreSQL
  module Cookbook
    module SqlHelpers
      module Connection
        include PostgreSQL::Cookbook::Utils

        private

        def postgresql_devel_pkg_name
          platform_family?('debian') ? 'libpq-dev' : "postgresql#{node['test']['pg_ver']}-devel"
        end

        def install_pg_gem
          return if gem_installed?('pg')

          with_run_context(:root) do
            declare_resource(:build_essential, 'Build Essential') { compile_time(true) }
            declare_resource(:package, postgresql_devel_pkg_name) { compile_time(true) }
            declare_resource(:chef_gem, 'pg') do
              options "-- --with-pg-include=/usr/pgsql-#{node['test']['pg_ver']}/include --with-pg-lib=/usr/pgsql-#{node['test']['pg_ver']}/lib"
              version '~> 1.4'
              compile_time true
            end
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
          node.run_state['postgresql_pg_connection'] ||= {}
          node.run_state['postgresql_pg_connection'][host] ||= {}
          node.run_state['postgresql_pg_connection'][host][dbname] ||= ::PG::Connection.new(**connection_params)

          node.run_state['postgresql_pg_connection'][host][dbname]
        end

        def execute_sql(query, max_one_result: false)
          # Query could be a String or an Array of Strings
          statement = query.is_a?(String) ? query : query.join("\n")

          Chef::Log.debug("Executing query: #{statement}")
          result = pg_client.exec(statement).to_a

          Chef::Log.debug("Got result: #{result}")
          return if result.empty?

          raise "Expected a single result, got #{result.count}" unless result.one? || !max_one_result

          result
        end
      end
    end
  end
end
