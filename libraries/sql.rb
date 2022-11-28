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
      include Chef::Mixin::ShellOut

      private

      def devel_pkg_name
        platform_family?('debian') ? 'libpq-dev' : "postgresql#{node['test']['pg_ver']}-devel"
      end

      def install_pg_gem
        with_run_context(:root) do
          declare_resource(:build_essential, '')
          declare_resource(:package, devel_pkg_name)
          declare_resource(:chef_gem, 'pg') { options("-- --with-pg-include=/usr/pgsql-#{node['test']['pg_ver']}/include --with-pg-lib=/usr/pgsql-#{node['test']['pg_ver']}/lib") }
        end
      end

      def psql_command_string(new_resource, query, grep_for: nil, value_only: false)
        cmd = %(/usr/bin/psql -c "#{query}")
        cmd << " -d #{new_resource.database}" if new_resource.database
        cmd << " -U #{new_resource.user}"     if new_resource.user
        cmd << " --host #{new_resource.host}" if new_resource.host
        cmd << " --port #{new_resource.port}" if new_resource.port
        cmd << ' --tuples-only'               if value_only
        cmd << ' --no-psqlrc'                 unless new_resource.psqlrc
        cmd << " | grep #{grep_for}"          if grep_for
        cmd
      end

      def execute_sql(new_resource, query)
        # If we don't pass in a user to the resource
        # default to the postgres user
        user = new_resource.user || 'postgres'

        # Query could be a String or an Array of Strings
        statement = query.is_a?(String) ? query : query.join("\n")

        # Pass back cmd so we can decide what to do with it in the calling method.
        shell_out(statement, user: user, environment: psql_environment)
      end

      def database_exists?(new_resource)
        sql = %(SELECT datname from pg_database WHERE datname='#{new_resource.database}')

        exists = psql_command_string(new_resource, sql, grep_for: new_resource.database)

        cmd = execute_sql(new_resource, exists)
        cmd.exitstatus == 0
      end

      def user_exists?(new_resource)
        sql = %(SELECT rolname FROM pg_roles WHERE rolname='#{new_resource.create_user}';)

        exists = psql_command_string(new_resource, sql, grep_for: new_resource.create_user)

        cmd = execute_sql(new_resource, exists)
        cmd.exitstatus == 0
      end

      def extension_installed?(new_resource)
        query = %(SELECT extversion FROM pg_extension WHERE extname='#{new_resource.extension}';)
        check_extension_version = psql_command_string(new_resource, query, value_only: true)
        version_result = execute_sql(new_resource, check_extension_version)
        if new_resource.version
          version_result.stdout == new_resource.version
        else
          !version_result.stdout.chomp.empty?
        end
      end

      def alter_role_sql(new_resource)
        sql = %(ALTER ROLE postgres ENCRYPTED PASSWORD '#{postgres_password(new_resource)}';)
        psql_command_string(new_resource, sql)
      end

      def create_extension_sql(new_resource)
        sql = %(CREATE EXTENSION IF NOT EXISTS \\\"#{new_resource.extension}\\\")
        sql << " FROM \"#{new_resource.old_version}\"" if new_resource.old_version

        psql_command_string(new_resource, sql)
      end

      def user_has_password?(new_resource)
        sql = %(SELECT rolpassword from pg_authid WHERE rolname='postgres' AND rolpassword IS NOT NULL;)
        cmd = psql_command_string(new_resource, sql)

        res = execute_sql(new_resource, cmd)
        res.stdout =~ /1 row/ ? true : false
      end

      def attribute_is_set?(user, attr, value)
        sql = %(SELECT rolconfig FROM pg_roles WHERE rolname='#{user}';)
        cmd = psql_command_string(new_resource, sql)

        res = execute_sql(new_resource, cmd)
        res.stdout.match(/#{attr}=#{value.delete('\'')}/)
      end

      def role_sql(new_resource)
        sql = %(\\"#{new_resource.create_user}\\" WITH )

        %w(superuser createdb createrole inherit replication login).each do |perm|
          sql << "#{'NO' unless new_resource.send(perm)}#{perm.upcase} "
        end

        sql << if new_resource.encrypted_password
                "ENCRYPTED PASSWORD '#{new_resource.encrypted_password}'"
              elsif new_resource.password
                "PASSWORD '#{new_resource.password}'"
              else
                ''
              end

        sql << if new_resource.valid_until
                " VALID UNTIL '#{new_resource.valid_until}'"
              else
                ''
              end
      end

      def create_user_sql(new_resource)
        sql = %(CREATE ROLE #{role_sql(new_resource)})
        psql_command_string(new_resource, sql)
      end

      def update_user_sql(new_resource)
        sql = %(ALTER ROLE #{role_sql(new_resource)})
        psql_command_string(new_resource, sql)
      end

      def update_user_with_attributes_sql(new_resource, attr, value)
        sql = %(ALTER ROLE \\"#{new_resource.create_user}\\" SET #{attr} = #{value})
        psql_command_string(new_resource, sql)
      end

      def drop_user_sql(new_resource)
        sql = %(DROP ROLE IF EXISTS \\"#{new_resource.create_user}\\")
        psql_command_string(new_resource, sql)
      end
    end
  end
end
