#
# Cookbook:: postgresql
# Resource:: install
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

unified_mode true

include PostgreSQL::Cookbook::Helpers

property :sensitive, [true, false],
          default: true

property :version, [String, Integer],
          default: '17',
          coerce: proc { |p| p.to_s },
          description: 'Version to install'

property :source, [String, Symbol],
          default: :repo,
          coerce: proc { |p| p.to_sym },
          equal_to: %i(repo os),
          description: 'Installation source'

property :client_packages, [String, Array],
          default: lazy { default_client_packages(version:, source:) },
          coerce: proc { |p| Array(p) },
          description: 'Client packages to install'

property :server_packages, [String, Array],
          default: lazy { default_server_packages(version:, source:) },
          coerce: proc { |p| Array(p) },
          description: 'Server packages to install'

property :repo_pgdg, [true, false],
          default: true,
          description: 'Enable pgdg repo'

property :setup_repo_pgdg, [true, false],
          default: lazy { |r| r.repo_pgdg },
          description: 'Setup pgdg repo. Defaults to value of `:repo_pgdg`.'

property :repo_pgdg_common, [true, false],
          default: true,
          description: 'Enable pgdg-common repo'

property :setup_repo_pgdg_common, [true, false],
          default: lazy { |r| r.repo_pgdg_common },
          description: 'Setup pgdg-common repo. Defaults to value of `:repo_pgdg_common`.'

property :repo_pgdg_source, [true, false],
          default: false,
          description: 'Enable pgdg-source repo'

property :setup_repo_pgdg_source, [true, false],
          default: lazy { |r| r.repo_pgdg_source },
          description: 'Setup pgdg-source repo. Defaults to value of `:repo_pgdg_source`.'

property :repo_pgdg_updates_testing, [true, false],
          default: false,
          description: 'Enable pgdg-updates-testing repo'

property :setup_repo_pgdg_updates_testing, [true, false],
          default: lazy { |r| r.repo_pgdg_updates_testing },
          description: 'Setup pgdg-updates-testing repo. Defaults to value of `:repo_pgdg_updates_testing`.'

property :repo_pgdg_source_updates_testing, [true, false],
          default: false,
          description: 'Enable pgdg-source-updates-testing repo'

property :setup_repo_pgdg_source_updates_testing, [true, false],
          default: lazy { |r| r.repo_pgdg_source_updates_testing },
          description: 'Setup pgdg-source-updates-testing repo. Defaults to value of `:repo_pgdg_source_updates_testing`.'

property :yum_gpg_key_uri, String,
          default: lazy { default_yum_gpg_key_uri },
          description: 'YUM/DNF GPG key URL'

property :apt_repository_uri, String,
          default: 'https://download.postgresql.org/pub/repos/apt/',
          description: 'apt repository URL'

property :apt_gpg_key_uri, String,
          default: 'https://download.postgresql.org/pub/repos/apt/ACCC4CF8.asc',
          description: 'apt GPG key URL'

property :initdb_additional_options, String,
          description: 'Additional options to pass to the initdb command'

property :initdb_locale, String,
          description: 'Locale to use for the initdb command'

property :initdb_encoding, String,
          description: 'Encoding to use for the initdb command'

property :initdb_user, String,
          default: 'postgres',
          description: 'User to run the initdb command as'

action_class do
  include PostgreSQL::Cookbook::Helpers

  def install_method_repo?
    new_resource.source.eql?(:repo)
  end

  def do_repository_action(repo_action)
    case node['platform_family']
    when 'rhel', 'amazon'
      # Disable the PostgreSQL module if we're on RHEL 8
      dnf_module 'postgresql' do
        action :disable
      end if dnf_module_platform?

      remote_file '/etc/pki/rpm-gpg/PGDG-RPM-GPG-KEY' do
        source new_resource.yum_gpg_key_uri
        sensitive new_resource.sensitive
      end

      yum_repository "PostgreSQL #{new_resource.version}" do
        repositoryid "pgdg#{new_resource.version}"
        description "PostgreSQL.org #{new_resource.version}"
        baseurl yum_repo_url('https://download.postgresql.org/pub/repos/yum')
        enabled new_resource.repo_pgdg
        gpgcheck true
        gpgkey 'file:///etc/pki/rpm-gpg/PGDG-RPM-GPG-KEY'
        action repo_action
        only_if { new_resource.repo_pgdg || new_resource.setup_repo_pgdg }
      end

      yum_repository 'PostgreSQL - common' do
        repositoryid 'pgdg-common'
        description 'PostgreSQL common RPMs for RHEL/CentOS $releasever - $basearch'
        baseurl yum_common_repo_url
        enabled new_resource.repo_pgdg_common
        gpgcheck true
        gpgkey 'file:///etc/pki/rpm-gpg/PGDG-RPM-GPG-KEY'
        action repo_action
        only_if { new_resource.repo_pgdg_common || new_resource.setup_repo_pgdg_common }
      end

      yum_repository "PostgreSQL #{new_resource.version} - source " do
        repositoryid "pgdg#{new_resource.version}-source"
        description "PostgreSQL.org #{new_resource.version} Source"
        baseurl yum_repo_url('https://download.postgresql.org/pub/repos/yum/srpms')
        make_cache false
        enabled new_resource.repo_pgdg_source
        gpgcheck true
        gpgkey 'file:///etc/pki/rpm-gpg/PGDG-RPM-GPG-KEY'
        action repo_action
        only_if { new_resource.repo_pgdg_source || new_resource.setup_repo_pgdg_source }
      end

      yum_repository "PostgreSQL #{new_resource.version} - updates testing" do
        repositoryid "pgdg#{new_resource.version}-updates-testing"
        description "PostgreSQL.org #{new_resource.version} Updates Testing"
        baseurl yum_repo_url('https://download.postgresql.org/pub/repos/yum/testing')
        make_cache false
        enabled new_resource.repo_pgdg_updates_testing
        gpgcheck true
        gpgkey 'file:///etc/pki/rpm-gpg/PGDG-RPM-GPG-KEY'
        action repo_action
        only_if { new_resource.repo_pgdg_updates_testing || new_resource.setup_repo_pgdg_updates_testing }
      end

      yum_repository "PostgreSQL #{new_resource.version} - source - updates testing" do
        repositoryid "pgdg#{new_resource.version}-source-updates-testing"
        description "PostgreSQL.org #{new_resource.version} Source Updates Testing"
        baseurl yum_repo_url('https://download.postgresql.org/pub/repos/yum/srpms/testing')
        make_cache false
        enabled new_resource.repo_pgdg_source_updates_testing
        gpgcheck true
        gpgkey 'file:///etc/pki/rpm-gpg/PGDG-RPM-GPG-KEY'
        action repo_action
        only_if { new_resource.repo_pgdg_source_updates_testing || new_resource.setup_repo_pgdg_source_updates_testing }
      end

    when 'debian'
      apt_update

      package 'apt-transport-https'

      apt_repository "postgresql_org_repository_#{new_resource.version.to_s}" do
        uri new_resource.apt_repository_uri
        components ['main', new_resource.version.to_s]
        distribution "#{node['lsb']['codename']}-pgdg"
        key new_resource.apt_gpg_key_uri
        cache_rebuild true
      end
    else
      raise "Unsupported platform_family #{node['platform_family']}  or platform #{node['platform']}"
    end
  end

  def do_client_package_action(package_action)
    package 'postgresql-client' do
      package_name new_resource.client_packages
      action package_action

      notifies :reload, 'ohai[postgresql_client_packages]', :immediately
    end

    ohai 'postgresql_client_packages' do
      plugin 'packages'

      action :nothing
    end
  end

  def do_server_package_action(package_action)
    if platform_family?('rhel') && node['platform_version'].to_i.eql?(7)
      package 'epel-release'
      package 'centos-release-scl'
    end

    package 'postgresql-server' do
      package_name new_resource.server_packages
      action package_action

      notifies :reload, 'ohai[postgresql_server_packages]', :immediately
    end

    ohai 'postgresql_server_packages' do
      plugin 'packages'

      action :nothing
    end
  end
end

action :install do
  run_action(:repository_create) if install_method_repo?
  run_action(:install_client)
  run_action(:install_server)
end

action :install_client do
  run_action(:repository_create) if install_method_repo?
  do_client_package_action(:install)
end

action :install_server do
  do_server_package_action(:install)

  if platform_family?('debian')
    initdb_options = ''
    initdb_options << "--locale #{new_resource.initdb_locale}" if new_resource.initdb_locale
    initdb_options << " -E #{new_resource.initdb_encoding}" if new_resource.initdb_encoding

    template '/etc/postgresql-common/createcluster.conf' do
      source 'createcluster.conf.erb'
      cookbook 'postgresql'
      variables(
        initdb_options:
      )
    end
  end
end

action :remove do
  run_action(:remove_client)
  run_action(:remove_server)
end

action :remove_client do
  do_client_package_action(:remove)
end

action :remove_server do
  do_server_package_action(:remove)
end

action :repository do
  do_repository_action(:create)
end

action :repository_create do
  do_repository_action(:create)
end

action :repository_delete do
  do_repository_action(:delete)
end

action :init_server do
  return if initialized? || !platform_family?('rhel', 'amazon')

  converge_by('Init PostgreSQL') do
    execute 'init_db' do
      command rhel_init_db_command(new_resource)
      user new_resource.initdb_user
    end
  end
end
