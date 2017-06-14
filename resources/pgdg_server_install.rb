# frozen_string_literal: true
#
# Cookbook:: postgresql
# Resource:: pgdg_server_install
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

property :version, String, required: true
property :packages, Array, required: true
property :data_directory, [String, nil], default: nil
property :setup_script, [String, nil], default: nil
property :ssl_cert_file, String, default: ''
property :ssl_key_file, String, default: ''

action :install do
  postgresql_setup = new_resource.setup_script || default_setup_script
  data_dir = new_resource.data_directory || default_data_directory(new_resource.version)

  package new_resource.packages

  # If using PGDG, add symlinks so that downstream commands all work
  [
    "postgresql#{shortver}-setup",
    "postgresql#{shortver}-check-db-dir",
  ].each do |cmd|
    link "/usr/bin/#{cmd}" do
      to "/usr/pgsql-#{new_resource.version}/bin/#{cmd}"
    end
  end

  if Chef::Platform::ServiceHelpers.service_resource_providers.include?(:systemd)
    execute "#{postgresql_setup} initdb #{svc_name}" do
      # debian packages do this automatically
      not_if { node['platform_family'] == 'debian' }
      # skip if database already setup
      not_if { ::File.exist?("#{data_dir}/PG_VERSION") }
    end
  else
    execute "/sbin/service #{svc_name} initdb" do
      not_if { node['platform_family'] == 'debian' }
      not_if { ::File.exist?("#{data_dir}/PG_VERSION") }
    end
  end

  with_run_context :root do
    service 'postgresql' do
      service_name svc_name
      action [:enable, :start]
    end
  end

  # Versions prior to 9.2 do not have a config file option to set the SSL
  # key and cert path, and instead expect them to be in a specific location.

  link ::File.join(data_dir, 'server.crt') do
    to new_resource.ssl_cert_file
    only_if { !new_resource.ssl_cert_file.empty? && new_resource.version.to_f < 9.2 }
  end

  link ::File.join(data_dir, 'server.key') do
    to new_resource.ssl_key_file
    only_if { !new_resource.ssl_key_file.empty? && new_resource.version.to_f < 9.2 }
  end
end

action_class do
  def svc_name
    "postgresql-#{new_resource.version}"
  end

  def shortver
    new_resource.version.split('.').join
  end

  def default_setup_script
    "postgresql#{shortver}-setup"
  end

  def default_data_directory(version)
    value_for_platform_family({
      ['rhel', 'fedora', 'suse'] => "/var/lib/pgsql/#{version}/data",
      ['debian'] => "/var/lib/postgresql/#{version}/main"
    })
  end
end
