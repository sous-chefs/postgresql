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

property :version, String, default: '10'
property :enable_pgdg, [true, false], default: false
property :enable_pgdg_source, [true, false], default: false
property :enable_pgdg_updates_testing, [true, false], default: true
property :enable_pgdg_source_updates_testing, [true, false], default: false

action :add do
  case node['platform_family']

  when 'rhel'
    remote_file "/etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG-#{new_resource.version}" do
      source "https://download.postgresql.org/pub/repos/yum/RPM-GPG-KEY-PGDG-#{new_resource.version}"
    end

    yum_repository "PostgreSQL #{new_resource.version} $releasever - $basearch" do
      repositoryid "pgdg#{new_resource.version}"
      baseurl     "https://download.postgresql.org/pub/repos/yum/#{new_resource.version}/redhat/rhel-$releasever-$basearch"
      enabled     new_resource.enable_pgdg
      gpgcheck    true
      gpgkey      "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG-#{new_resource.version}"
    end

    yum_repository "PostgreSQL #{new_resource.version} $releasever - $basearch - source " do
      repositoryid "pgdg#{new_resource.version}-source"
      baseurl     "https://download.postgresql.org/pub/repos/yum/srpms/#{new_resource.version}/redhat/rhel-$releasever-$basearch"
      enabled     new_resource.enable_pgdg_source
      gpgcheck    true
      gpgkey      "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG-#{new_resource.version}"
    end

    yum_repository "PostgreSQL #{new_resource.version} $releasever - $basearch - updates testing" do
      repositoryid "pgdg#{new_resource.version}-updates-testing"
      baseurl     "https://download.postgresql.org/pub/repos/yum/testing/#{new_resource.version}/redhat/rhel-$releasever-$basearch"
      enabled     new_resource.enable_pgdg_updates_testing
      gpgcheck    true
      gpgkey      "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG-#{new_resource.version}"
    end

    yum_repository "PostgreSQL #{new_resource.version} $releasever - $basearch - source - updates testing" do
      repositoryid "pgdg#{new_resource.version}-source-updates-testing"
      baseurl     "https://download.postgresql.org/pub/repos/yum/srpms/testing/#{new_resource.version}/redhat/rhel-$releasever-$basearch"
      enabled     new_resource.enable_pgdg_source_updates_testing
      gpgcheck    true
      gpgkey      "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG-#{new_resource.version}"
    end

  when 'debian'
    remote_file "#{Chef::Config[:file_cache_path]}/ACCC4CF8.asc" do
      source 'https://www.postgresql.org/media/keys/ACCC4CF8.asc'
      notifies :run, 'bash[apt-key-add]', :immediately
    end

    apt_update 'update'
    package 'apt-transport-https'

    bash 'apt-key-add' do
      code "sudo apt-key add #{Chef::Config[:file_cache_path]}/ACCC4CF8.asc"
      action :nothing
    end

    apt_repository 'name' do
      uri          'https://apt.postgresql.org/pub/repos/apt/'
      components   ['main', new_resource.version.to_s]
      distribution "#{node['lsb']['codename']}-pgdg"
      cache_rebuild true
    end
  end
end
