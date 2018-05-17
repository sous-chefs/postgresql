#
# Cookbook:: postgresql
# Library:: helpers
# Author:: David Crane (<davidc@donorschoose.org>)
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

include Chef::Mixin::ShellOut

module PostgresqlCookbook
  module Helpers
    #######
    # Function to execute an SQL statement in the default database.
    #   Input: Query could be a single String or an Array of String.
    #   Output: A String with |-separated columns and \n-separated rows.
    #           Note an empty output could mean psql couldn't connect.
    # This is easiest for 1-field (1-row, 1-col) results, otherwise
    # it will be complex to parse the results.
    def execute_sql(query, db_name)
      # query could be a String or an Array of String
      statement = query.is_a?(String) ? query : query.join("\n")
      cmd = shell_out("psql -q --tuples-only --no-align -d #{db_name} -f -",
                      user: 'postgres',
                      input: statement)
      # If psql fails, generally the postgresql service is down.
      # Instead of aborting chef with a fatal error, let's just
      # pass these non-zero exitstatus back as empty cmd.stdout.
      if cmd.exitstatus == 0 && !cmd.stderr.empty?
        # An SQL failure is still a zero exitstatus, but then the
        # stderr explains the error, so let's rais that as fatal.
        Chef::Log.fatal("psql failed executing this SQL statement:\n#{statement}")
        Chef::Log.fatal(cmd.stderr)
        raise 'SQL ERROR'
      end
      cmd.stdout.chomp
    end

    def database_exists?(new_resource)
      sql = %(SELECT datname from pg_database WHERE datname='#{new_resource.database}')

      exists = %(psql -c "#{sql}")
      exists << " -U #{new_resource.user}" if new_resource.user
      exists << " --host #{new_resource.host}" if new_resource.host
      exists << " --port #{new_resource.port}" if new_resource.port
      exists << " | grep #{new_resource.database}"

      cmd = Mixlib::ShellOut.new(exists, user: 'postgres')
      cmd.run_command
      cmd.exitstatus == 0
    end

    def user_exists?(new_resource)
      exists = %(psql -c "SELECT rolname FROM pg_roles WHERE rolname='#{new_resource.user}'" | grep '#{new_resource.user}')

      cmd = Mixlib::ShellOut.new(exists, user: 'postgres')
      cmd.run_command
      cmd.exitstatus == 0
    end

    def role_sql(new_resource)
      sql = %(\\\"#{new_resource.user}\\\" WITH )

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

    def extension_installed?
      query = "SELECT 'installed' FROM pg_extension WHERE extname = '#{new_resource.extension}';"
      !(execute_sql(query, new_resource.database) =~ /^installed$/).nil?
    end

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

    def psql_command_string(database, query)
      "psql -d #{database} <<< '\\set ON_ERROR_STOP on\n#{query};'"
    end

    def slave?
      ::File.exist? "#{data_dir}/recovery.conf"
    end
  end
end
