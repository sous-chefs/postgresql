# frozen_string_literal: true
#
# Cookbook:: postgresql
# Resource:: repository
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

property :version,                            String, default: '9.6'
property :enable_pgdg,                        [true, false], default: true
property :enable_pgdg_source,                 [true, false], default: false
property :enable_pgdg_updates_testing,        [true, false], default: false
property :enable_pgdg_source_updates_testing, [true, false], default: false
property :yum_gpg_key_uri, String, default: 'https://download.postgresql.org/pub/repos/yum/RPM-GPG-KEY-PGDG'
property :apt_gpg_key_uri, String, default: 'https://download.postgresql.org/pub/repos/apt/ACCC4CF8.asc'

action :add do
  case node['platform_family']

  when 'rhel', 'fedora', 'amazon'
    remote_file "/etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG-#{new_resource.version}" do
      source new_resource.yum_gpg_key_uri
    end

    yum_repository "PostgreSQL #{new_resource.version}" do # ~FC005
      repositoryid "pgdg#{new_resource.version}"
      description "PostgreSQL.org #{new_resource.version}"
      baseurl     yum_repo_url('https://download.postgresql.org/pub/repos/yum')
      enabled     new_resource.enable_pgdg
      gpgcheck    true
      gpgkey      "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG-#{new_resource.version}"
    end

    yum_repository "PostgreSQL #{new_resource.version} - source " do
      repositoryid "pgdg#{new_resource.version}-source"
      description "PostgreSQL.org #{new_resource.version} Source"
      baseurl     yum_repo_url('https://download.postgresql.org/pub/repos/yum/srpms')
      enabled     new_resource.enable_pgdg_source
      gpgcheck    true
      gpgkey      "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG-#{new_resource.version}"
    end

    yum_repository "PostgreSQL #{new_resource.version} - updates testing" do
      repositoryid "pgdg#{new_resource.version}-updates-testing"
      description "PostgreSQL.org #{new_resource.version} Updates Testing"
      baseurl     yum_repo_url('https://download.postgresql.org/pub/repos/yum/testing')
      enabled     new_resource.enable_pgdg_updates_testing
      gpgcheck    true
      gpgkey      "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG-#{new_resource.version}"
    end

    yum_repository "PostgreSQL #{new_resource.version} - source - updates testing" do
      repositoryid "pgdg#{new_resource.version}-source-updates-testing"
      description "PostgreSQL.org #{new_resource.version} Source Updates Testing"
      baseurl     yum_repo_url('https://download.postgresql.org/pub/repos/yum/srpms/testing')
      enabled     new_resource.enable_pgdg_source_updates_testing
      gpgcheck    true
      gpgkey      "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG-#{new_resource.version}"
    end

  when 'debian'
    apt_update

    package 'apt-transport-https'

    apt_repository 'postgresql_org_repository' do
      uri          'https://download.postgresql.org/pub/repos/apt/'
      components   ['main', new_resource.version.to_s]
      distribution "#{node['lsb']['codename']}-pgdg"
      key new_resource.apt_gpg_key_uri
      cache_rebuild true
    end
  else
    raise "The platform_family '#{node['platform_family']}' or platform '#{node['platform']}' is not supported by the postgresql_repository resource. If you believe this platform can/should be supported by this resource please file and issue or open a pull request at https://github.com/sous-chefs/postgresql"
  end
end

action_class do
  include PostgresqlCookbook::Helpers
end
