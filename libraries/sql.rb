#
# Cookbook:: postgresql
# Library:: sql
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

        key = nil_or_empty?(connection_params.fetch(:host, nil)) ? :local_socket : new_resource.host
        client = node.run_state.dig('postgresql_pg_connection', key)

        if client.is_a?(::PG::Connection)
          Chef::Log.info("Returning pre-existing client for #{key}")
          return client
        end

        Chef::Log.warn("Creating client for #{key}")
        node.run_state['postgresql_pg_connection'] ||= {}
        node.run_state['postgresql_pg_connection'][key] ||= ::PG::Connection.new(**connection_params)

        node.run_state['postgresql_pg_connection'][key]
      end

      def execute_sql(query, max_one_result: false)
        # Query could be a String or an Array of Strings
        statement = query.is_a?(String) ? query : query.join("\n")

        Chef::Log.warn("Executing query: #{statement}")
        result = pg_client.exec(statement).to_a

        Chef::Log.info("Got result: #{result}")

        raise "Expected a single result, got #{result.count}" unless result.empty? || (result.one? || !max_one_result)

        result
      end

      def pg_database?(new_resource)
        sql = "SELECT datname from pg_database WHERE datname='#{new_resource.database}'"
        database = execute_sql(sql, max_one_result: true)

        !database.empty?
      end

      def pg_role(name)
        sql = "SELECT * FROM pg_roles WHERE rolname='#{name}';"
        role = execute_sql(sql)

        return if role.to_a.empty?

        role = role.to_a.pop

        role.transform_values do |v|
          case v
          when 't'
            true
          when 'f'
            false
          else
            v
          end
        end
      end

      def pg_role?(name)
        sql = %(SELECT rolname FROM pg_roles WHERE rolname='#{name}';)
        role = execute_sql(sql, max_one_result: true)

        !role.empty?
      end

      def pg_role_password?(name)
        sql = "SELECT rolpassword from pg_roles WHERE rolname='#{name}' AND rolpassword IS NOT NULL;"
        password = execute_sql(sql, max_one_result: true)

        !password.empty?
      end

      def pg_extension?(new_resource)
        query = %(SELECT extversion FROM pg_extension WHERE extname='#{new_resource.extension}';)
        check_extension_version = psql_command_string(new_resource, query, value_only: true)
        version_result = execute_sql(new_resource, check_extension_version)
        if new_resource.version
          version_result.stdout == new_resource.version
        else
          !version_result.stdout.chomp.empty?
        end
      end

      def pg_attribute?(role, attribute, value)
        sql = %(SELECT rolconfig FROM pg_roles WHERE rolname='#{role}';)
        attribute_config = execute_sql(sql, max_one_result: true).fetch('rolconfig')
        Chef::Log.warn("AC: #{attribute_config}")

        attribute_config.delete_prefix!('{')
        attribute_config.delete_suffix!('}')
        attribute_config = attribute_config.split(',').map { |rcv| rcv.split('=') }.to_h
        attribute_config.transform_values! do |v|
          case v
          when 'on'
            true
          when 'off'
            false
          else v
          end
        end

        Chef::Log.warn("AC Parsed: #{attribute_config}")
        Chef::Log.warn("AC Testing: #{attribute} | #{value}")

        attribute_config.fetch(attribute).eql?(value)
      end

      ###
      ## Generators
      ###

      ## Role

      def role_sql(new_resource)
        sql = []

        sql.push("ROLE #{new_resource.rolename} WITH")

        %i(superuser createdb createrole inherit login replication bypassrls).each do |perm|
          unless new_resource.send(perm)
            sql.push("NO#{perm.to_s.upcase.gsub('_', ' ')}")
            next
          end

          sql.push("#{perm.to_s.upcase.gsub('_', ' ')}")
        end

        sql.push("CONNECTION LIMIT #{new_resource.connection_limit}")

        if new_resource.encrypted_password
          sql.push("ENCRYPTED PASSWORD '#{new_resource.encrypted_password}'")
        elsif new_resource.unencrypted_password
          sql.push("PASSWORD '#{new_resource.unencrypted_password}'")
        else
          sql.push('PASSWORD NULL')
        end

        sql.push("VALID UNTIL '#{new_resource.valid_until}'") if new_resource.valid_until

        unless new_resource.action.eql?(:update)
          sql.push("IN ROLE #{new_resource.role}") if new_resource.in_role
          sql.push("ROLE #{new_resource.role}") if new_resource.role
          sql.push("ADMIN #{new_resource.role}") if new_resource.admin
        end

        "#{sql.join(' ').strip};"
      end

      def create_role(new_resource)
        sql = "CREATE #{role_sql(new_resource)}"
        execute_sql(sql)
      end

      def update_role(new_resource)
        sql = "ALTER #{role_sql(new_resource)}"
        execute_sql(sql)
      end

      def drop_role(new_resource)
        sql = "DROP ROLE #{new_resource.rolename}"
        execute_sql(sql)
      end

      def alter_role_password_sql(new_resource)
        sql = %(ALTER ROLE postgres ENCRYPTED PASSWORD '#{postgres_password(new_resource)}';)
        execute_sql(sql)
      end

      def update_role_with_attributes_sql(new_resource, attr, value)
        sql = %(ALTER ROLE \\"#{new_resource.create_role}\\" SET #{attr} = #{value})
        execute_sql(sql)
      end

      def create_extension_sql(new_resource)
        sql = %(CREATE EXTENSION IF NOT EXISTS \\\"#{new_resource.extension}\\\")
        sql << " FROM \"#{new_resource.old_version}\"" if new_resource.old_version

        execute_sql(sql)
      end
    end
  end
end
