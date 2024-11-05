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

require_relative '_utils'
require 'securerandom'

module PostgreSQL
  module Cookbook
    module Helpers
      include Utils

      def installed_postgresql_package_logic
        pgsql_package = node['packages'].filter { |p| p.match?(/^postgresql-?(\d+)?$/) }.values

        unless pgsql_package.one?
          versions = pgsql_package.map { |values| values['version'] }.join(', ')
          Chef::Log.warn("Detected #{pgsql_package.count} installed PostgreSQL versions: #{versions}. Using latest version.")
          pgsql_package = [pgsql_package.max_by { |values| values['version'].to_f }]
        end

        raise 'Unable to determine installed PostgreSQL version' if nil_or_empty?(pgsql_package)

        pgsql_package.first
      end

      def installed_postgresql_major_version
        pgsql_package = installed_postgresql_package_logic
        pgsql_package_version = pgsql_package.fetch('version').to_i
        pgsql_package_source = if pgsql_package.key?('release')
                                 pgsql_package.fetch('release').match?('PGDG') ? :repo : :os
                               else
                                 pgsql_package.fetch('version').match?('pgdg') ? :repo : :os
                               end

        Chef::Log.info("Detected installed PostgreSQL version: #{pgsql_package_version} installed from #{pgsql_package_source}")

        pgsql_package_version
      end

      def installed_postgresql_package_source
        pgsql_package = installed_postgresql_package_logic
        pgsql_package_version = pgsql_package.fetch('version').to_i
        pgsql_package_source = if pgsql_package.key?('release')
                                 pgsql_package.fetch('release').match?('PGDG') ? :repo : :os
                               else
                                 pgsql_package.fetch('version').match?('pgdg') ? :repo : :os
                               end

        Chef::Log.info("Detected installed PostgreSQL version: #{pgsql_package_version} installed from #{pgsql_package_source}")

        pgsql_package_source
      end

      def data_dir(version: installed_postgresql_major_version, source: installed_postgresql_package_source)
        case node['platform_family']
        when 'rhel', 'amazon'
          source.eql?(:repo) ? "/var/lib/pgsql/#{version}/data" : '/var/lib/pgsql/data'
        when 'debian'
          "/var/lib/postgresql/#{version}/main"
        end
      end

      def conf_dir(version: installed_postgresql_major_version, source: installed_postgresql_package_source)
        case node['platform_family']
        when 'rhel', 'amazon'
          source.eql?(:repo) ? "/var/lib/pgsql/#{version}/data" : '/var/lib/pgsql/data'
        when 'debian'
          "/etc/postgresql/#{version}/main"
        end
      end

      # determine the platform specific service name
      def default_platform_service_name(version: installed_postgresql_major_version, source: installed_postgresql_package_source)
        if platform_family?('rhel', 'amazon') && source.eql?(:repo)
          "postgresql-#{version}"
        else
          'postgresql'
        end
      end

      def follower?
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

      def default_server_packages(version: nil, source: :os)
        case node['platform_family']
        when 'rhel'
          {
            os: %w(libpq postgresql-contrib postgresql-server),
            repo: %W(postgresql#{version.delete('.')}-contrib postgresql#{version.delete('.')}-server),
          }.fetch(source, nil)
        when 'amazon'
          {
            os: %W(postgresql#{version.delete('.')}-contrib postgresql#{version.delete('.')}-server),
            repo: %W(postgresql#{version.delete('.')}-contrib postgresql#{version.delete('.')}-server),
          }.fetch(source, nil)
        when 'debian'
          {
            os: %w(libpq5 postgresql postgresql-common),
            repo: %W(postgresql-#{version} postgresql-common),
          }.fetch(source, nil)
        end
      end

      def default_client_packages(version: nil, source: :os)
        case node['platform_family']
        when 'rhel'
          {
            os: %w(postgresql),
            repo: %W(postgresql#{version.delete('.')}),
          }.fetch(source, nil)
        when 'amazon'
          {
            os: %W(postgresql#{version.delete('.')}),
            repo: %W(postgresql#{version.delete('.')}),
          }.fetch(source, nil)
        when 'debian'
          {
            os: %w(postgresql-client),
            repo: %W(postgresql-client-#{version}),
          }.fetch(source, nil)
        end
      end

      def default_yum_gpg_key_uri
        if platform_family?('rhel') && node['platform_version'].to_i == 7
          'https://download.postgresql.org/pub/repos/yum/keys/PGDG-RPM-GPG-KEY-RHEL7'
        else
          'https://download.postgresql.org/pub/repos/yum/keys/PGDG-RPM-GPG-KEY-RHEL'
        end
      end

      def dnf_module_platform?
        (platform_family?('rhel') && node['platform_version'].to_i == 8)
      end

      # determine the appropriate DB init command to run based on RHEL/Amazon release
      # initdb defaults to the execution environment.
      # https://www.postgresql.org/docs/9.5/static/locale.html
      def rhel_init_db_command(new_resource)
        cmd = new_resource.source.eql?(:repo) ? "/usr/pgsql-#{new_resource.version}/bin/initdb" : '/usr/bin/initdb'
        cmd << " --locale '#{new_resource.initdb_locale}'" if new_resource.initdb_locale
        cmd << " -E '#{new_resource.initdb_encoding}'" if new_resource.initdb_encoding
        cmd << " #{new_resource.initdb_additional_options}" if new_resource.initdb_additional_options
        cmd << " -D '#{data_dir}'"
      end

      # Given the base URL build the complete URL string for a yum repo
      def yum_repo_url(base_url)
        "#{base_url}/#{new_resource.version}/redhat/#{yum_repo_platform_string}"
      end

      # Given the base URL build the complete URL string for a yum repo
      def yum_common_repo_url
        "https://download.postgresql.org/pub/repos/yum/common/redhat/#{yum_repo_platform_string}"
      end

      # Build the platform string that makes up the final component of the yum repo URL
      def yum_repo_platform_string
        release = platform?('amazon') ? '8' : '$releasever'
        "rhel-#{release}-$basearch"
      end

      # On Amazon use the RHEL 8 packages. Otherwise use the releasever yum variable
      def yum_releasever
        platform?('amazon') ? '8' : '$releasever'
      end

      # Generate a password if the value is set to generate.
      def postgres_password(new_resource)
        new_resource.password == 'generate' ? secure_random : new_resource.password
      end
    end
  end
end
