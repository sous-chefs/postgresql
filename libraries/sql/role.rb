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

require_relative '../_utils'
require_relative '_connection'
require_relative '_utils'

module PostgreSQL
  module Cookbook
    module SqlHelpers
      module Role
        private

        include PostgreSQL::Cookbook::Utils
        include PostgreSQL::Cookbook::SqlHelpers::Connection
        include Utils

        def pg_role(name)
          sql = 'SELECT * FROM pg_roles WHERE rolname=$1'
          role = execute_sql_params(sql, [ name ])

          return if role.to_a.empty?

          role = role.to_a.pop
          map_pg_values!(role)

          role
        end

        def pg_role?(name)
          sql = 'SELECT rolname FROM pg_roles WHERE rolname=$1'
          role = execute_sql_params(sql, [ name ], max_one_result: true)

          !nil_or_empty?(role)
        end

        def pg_role_password?(name)
          sql = 'SELECT rolpassword from pg_roles WHERE rolname=$1 AND rolpassword IS NOT NULL'
          password = execute_sql_params(sql, [ name ], max_one_result: true)

          !nil_or_empty?(password)
        end

        def pg_role_encrypted_password(name)
          sql = 'SELECT rolpassword FROM pg_authid WHERE rolname=$1 AND rolpassword IS NOT NULL'
          authid = execute_sql_params(sql, [ name], max_one_result: true)

          authid&.to_a&.pop&.fetch('rolpassword')
        end

        def role_sql(new_resource)
          sql = []

          sql.push("ROLE \"#{new_resource.rolename}\" WITH")

          %i(superuser createdb createrole inherit login replication bypassrls).each do |perm|
            next unless property_is_set?(perm)

            if new_resource.send(perm)
              sql.push("#{perm.to_s.upcase.gsub('_', ' ')}")
            else
              sql.push("NO#{perm.to_s.upcase.gsub('_', ' ')}")
            end
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
            sql.push("IN ROLE #{new_resource.in_role}") if new_resource.in_role
            sql.push("ROLE #{new_resource.role}") if new_resource.role
            sql.push("ADMIN #{new_resource.admin}") if new_resource.admin
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

        def update_role_password(new_resource)
          sql = []

          sql.push("ALTER ROLE \"#{new_resource.rolename}\"")

          if new_resource.encrypted_password
            sql.push("ENCRYPTED PASSWORD '#{new_resource.encrypted_password}'")
          elsif new_resource.unencrypted_password
            sql.push("PASSWORD '#{new_resource.unencrypted_password}'")
          else
            sql.push('PASSWORD NULL')
          end

          execute_sql("#{sql.join(' ').strip};")
        end

        # def update_role_with_attributes_sql(new_resource, attr, value)
        #   sql = %(ALTER ROLE \\"#{new_resource.create_role}\\" SET #{attr} = #{value})
        #   execute_sql(sql)
        # end
      end
    end
  end
end
