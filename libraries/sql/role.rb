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

require_relative '_connection'
require_relative '_utils'

module PostgreSQL
  module Cookbook
    module SqlHelpers
      module Role
        include PostgreSQL::Cookbook::SqlHelpers::Connection
        include Utils

        private

        def pg_role(name)
          sql = "SELECT * FROM pg_roles WHERE rolname='#{name}';"
          role = execute_sql(sql)

          return if role.to_a.empty?

          role = role.to_a.pop
          map_pg_values!(role)

          role
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

        def role_sql(new_resource)
          sql = []

          sql.push("ROLE \"#{new_resource.rolename}\" WITH")

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
          execute_sql("CREATE #{role_sql(new_resource)}")
        end

        def set_role_configuration(new_resource)
          execute_sql("ALTER ROLE \"#{new_resource.rolename}\" RESET ALL;")
          new_resource.config.each { |k, v| execute_sql("ALTER ROLE \"#{new_resource.rolename}\" SET \"#{k}\" = \"#{v}\";") }
        end

        def update_role(new_resource)
          execute_sql("ALTER #{role_sql(new_resource)}")
        end

        def drop_role(new_resource)
          execute_sql("DROP ROLE \"#{new_resource.rolename}\"")
        end

        # def alter_role_password_sql(new_resource)
        #   sql = %(ALTER ROLE postgres ENCRYPTED PASSWORD '#{postgres_password(new_resource)}';)
        #   execute_sql(sql)
        # end

        # def update_role_with_attributes_sql(new_resource, attr, value)
        #   sql = %(ALTER ROLE \\"#{new_resource.create_role}\\" SET #{attr} = #{value})
        #   execute_sql(sql)
        # end
      end
    end
  end
end
