unified_mode true

property :version,                            [String], default: '12'
property :enable_pgdg,                        [true, false], default: true
property :enable_pgdg_common,                 [true, false], default: true
property :enable_pgdg_source,                 [true, false], default: false
property :enable_pgdg_updates_testing,        [true, false], default: false
property :enable_pgdg_source_updates_testing, [true, false], default: false
property :yum_gpg_key_uri, String, default: 'https://download.postgresql.org/pub/repos/yum/RPM-GPG-KEY-PGDG'
property :apt_gpg_key_uri, String, default: 'https://download.postgresql.org/pub/repos/apt/ACCC4CF8.asc'

action :add do
  case node['platform_family']

  when 'rhel', 'fedora', 'amazon'

    remote_file '/etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG' do
      source new_resource.yum_gpg_key_uri
    end

    execute 'dnf -qy module disable postgresql' do
      only_if { (node['platform_version'].to_i > 7 && platform_family?('rhel')) || platform_family?('fedora') }
      not_if 'dnf module list postgresql | grep -q "^postgresql.*\[x\]"'
    end

    yum_repository "PostgreSQL #{new_resource.version}" do
      repositoryid "pgdg#{new_resource.version}"
      description "PostgreSQL.org #{new_resource.version}"
      baseurl     yum_repo_url('https://download.postgresql.org/pub/repos/yum')
      enabled     new_resource.enable_pgdg
      gpgcheck    true
      gpgkey      'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG'
    end

    yum_repository 'Postgresql - common' do
      repositoryid 'pgdg-common'
      description 'PostgreSQL common RPMs for RHEL/CentOS $releasever - $basearch'
      baseurl yum_common_repo_url
      enabled new_resource.enable_pgdg_common
      gpgcheck true
      gpgkey 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG'
    end

    yum_repository "PostgreSQL #{new_resource.version} - source " do
      repositoryid "pgdg#{new_resource.version}-source"
      description "PostgreSQL.org #{new_resource.version} Source"
      baseurl     yum_repo_url('https://download.postgresql.org/pub/repos/yum/srpms')
      enabled     new_resource.enable_pgdg_source
      gpgcheck    true
      gpgkey      'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG'
    end

    yum_repository "PostgreSQL #{new_resource.version} - updates testing" do
      repositoryid "pgdg#{new_resource.version}-updates-testing"
      description "PostgreSQL.org #{new_resource.version} Updates Testing"
      baseurl     yum_repo_url('https://download.postgresql.org/pub/repos/yum/testing')
      enabled     new_resource.enable_pgdg_updates_testing
      gpgcheck    true
      gpgkey      'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG'
    end

    yum_repository "PostgreSQL #{new_resource.version} - source - updates testing" do
      repositoryid "pgdg#{new_resource.version}-source-updates-testing"
      description "PostgreSQL.org #{new_resource.version} Source Updates Testing"
      baseurl     yum_repo_url('https://download.postgresql.org/pub/repos/yum/srpms/testing')
      enabled     new_resource.enable_pgdg_source_updates_testing
      gpgcheck    true
      gpgkey      'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG'
    end

  when 'debian'
    apt_update

    package 'apt-transport-https'

    apt_repository "postgresql_org_repository_#{new_resource.version.to_s}" do
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
