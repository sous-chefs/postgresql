#
# Cookbook:: postgresql
# Library:: helpers
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
    include Chef::Mixin::ShellOut

    require 'securerandom'

    def psql_command_string(new_resource, query, grep_for = nil)
      cmd = "psql -tc '#{query}'"
      cmd << " -d #{new_resource.database}" if new_resource.database
      cmd << " -U #{new_resource.user}"     if new_resource.user
      cmd << " --host #{new_resource.host}" if new_resource.host
      cmd << " --port #{new_resource.port}" if new_resource.port
      cmd << " | grep #{grep_for}"          if grep_for
      cmd
    end

    #######
    # Function to execute an SQL statement in the default database.
    #   Input: Query could be a single String or an Array of String.
    #   Output: A String with |-separated columns and \n-separated rows.
    #           Note an empty output could mean psql couldn't connect.
    # This is easiest for 1-field (1-row, 1-col) results, otherwise
    # it will be complex to parse the results.
    def execute_sql(new_resource, query)
      # Let's build up a full command
      psql = psql_command_string(new_resource, query, new_resource.database)

      # If we don't pass in a user to the resource
      # default to the postgres user
      user = new_resource.user ? new_resource.user : 'postgres'

      # query could be a String or an Array of Strings
      statement = query.is_a?(String) ? query : query.join("\n")

      cmd = shell_out(psql, user: user, input: statement)
      # If psql fails, generally the postgresql service is down.
      # Instead of aborting chef with a fatal error, let's just
      # pass these non-zero exitstatus back as empty cmd.stdout.
      if cmd.exitstatus == 0 && !cmd.error?
        # An SQL failure is still a zero exitstatus, but then the
        # stderr explains the error, so let's raise that as fatal.
        Chef::Log.fatal("psql failed executing this SQL statement:\n#{statement}")
        Chef::Log.fatal(cmd.stderr)
        raise 'SQL ERROR'
      end
      cmd.stdout.chomp
    end

    def database_exists?(new_resource)
      sql = %(SELECT datname from pg_database WHERE datname='#{new_resource.database}')

      exists = psql_command_string(new_resource, sql)

      cmd = shell_out(exists, user: 'postgresql')
      cmd.run_command
      cmd.exitstatus == 0
    end

    def user_exists?(new_resource)
      sql = %(SELECT rolname FROM pg_roles WHERE rolname='#{new_resource.user}'" | grep '#{new_resource.user}')
      execute_sql(new_resource, sql)
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
      when 'rhel', 'fedora'
        "/var/lib/pgsql/#{version}/data"
      when 'amazon'
        "/var/lib/pgsql#{version.delete('.')}/data"
      when 'debian'
        "/var/lib/postgresql/#{version}/main"
      end
    end

    def conf_dir(version = node.run_state['postgresql']['version'])
      case node['platform_family']
      when 'rhel', 'fedora'
        "/var/lib/pgsql/#{version}/data"
      when 'amazon'
        if node['virtualization']['system'] == 'docker'
          "/var/lib/pgsql#{version.delete('.')}/data"
        else
          "/var/lib/pgsql/#{version}/data"
        end
      when 'debian'
        "/etc/postgresql/#{version}/main"
      end
    end

    # determine the platform specific service name
    def platform_service_name(version = node.run_state['postgresql']['version'])
      case node['platform_family']
      when 'rhel', 'fedora'
        "postgresql-#{version}"
      when 'amazon'
        if node['virtualization']['system'] == 'docker'
          "postgresql#{version.delete('.')}"
        else
          "postgresql-#{version}"
        end
      else
        'postgresql'
      end
    end

    def slave?
      ::File.exist? "#{data_dir}/recovery.conf"
    end

    def initialized?
      return true if ::File.exist?("#{conf_dir}/PG_VERSION")
      false
    end

    def secure_random
      r = SecureRandom.hex
      Chef::Log.debug "Generated password: #{r}"
      r
    end

    # determine the platform specific server package name
    def server_pkg_name
      platform_family?('debian') ? "postgresql-#{new_resource.version}" : "postgresql#{new_resource.version.delete('.')}-server"
    end

    # determine the appropriate DB init command to run based on RHEL/Fedora/Amazon release
    def rhel_init_db_command
      if platform_family?('fedora') || (platform_family?('rhel') && node['platform_version'].to_i >= 7)
        "/usr/pgsql-#{new_resource.version}/bin/postgresql#{new_resource.version.delete('.')}-setup initdb"
      else
        "service #{platform_service_name} initdb"
      end
    end

    # given the base URL build the complete URL string for a yum repo
    def yum_repo_url(base_url)
      "#{base_url}/#{new_resource.version}/#{yum_repo_platform_family_string}/#{yum_repo_platform_string}"
    end

    # the postgresql yum repos URLs are organized into redhat and fedora directories.s
    # route things to the right place based on platform_family
    def yum_repo_platform_family_string
      platform_family?('fedora') ? 'fedora' : 'redhat'
    end

    # build the platform string that makes up the final component of the yum repo URL
    def yum_repo_platform_string
      platform = platform?('fedora') ? 'fedora' : 'rhel'
      release = platform?('amazon') ? '6' : '$releasever'
      "#{platform}-#{release}-$basearch"
    end

    # on amazon use the RHEL 6 packages. Otherwise use the releasever yum variable
    def yum_releasever
      platform?('amazon') ? '6' : '$releasever'
    end
  end
end
