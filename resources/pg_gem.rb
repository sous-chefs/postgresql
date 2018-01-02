# frozen_string_literal: true
#
# Cookbook:: postgresql
# Resource:: pg_gem
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

property :client_version, String, default: '9.6'
property :version,       [String, nil], default: '0.21.0'
property :setup_repo,    [true, false], default: true
property :source,        [String, nil], default: nil
# gem options
property :clear_sources,          [true, false]
property :include_default_source, [true, false]
property :gem_binary,             String
property :options,                [String, Hash]
property :source,                 [String, Array]
property :timeout,                Integer, default: 300
property :version,                String
property :ruby_binary,            String

action :install do
  # Needed for the client
  postgresql_repository 'Add downloads.postgresql.org repository' do
    only_if { new_resource.setup_repo }
    action :nothing
  end.run_action :add

  package 'Install gem dependencies' do
    case node['platform_family']
    when 'debian'
      package_name [
        'libpq5',
        'libpq-dev',
        'libpq-dev',
        "postgresql-client-#{new_resource.client_version}",
        'libgmp-dev',
      ]
    when 'rhel', 'fedora', 'amazon'
      ver = new_resource.client_version.delete('.')
      package_name [
        'postgresql-devel',
        "postgresql#{ver}",
      ]
    end
    action :nothing
  end.run_action :install

  build_essential 'essentially essential' do
    compile_time true
  end

  raise ArgumentError, 'pg gem requires a system Ruby installation of 2.0 or higher.' if ruby_version < 2.0

  gem_package 'pg' do
    clear_sources new_resource.clear_sources if new_resource.clear_sources
    include_default_source new_resource.include_default_source if new_resource.include_default_source
    gem_binary new_resource.gem_binary if new_resource.gem_binary
    options new_resource.options if new_resource.options
    source new_resource.source if new_resource.source
    timeout new_resource.timeout if new_resource.timeout
    version new_resource.version if new_resource.version
    action :install
  end
end

action_class do
  def ruby_bin
    if new_resource.ruby_binary
      new_resource.ruby_binary
    else
      '/usr/bin/ruby'
    end
  end

  def ruby_version
    require 'mixlib/shellout'
    v = Mixlib::ShellOut.new("#{ruby_bin} -v").run_command
    v.stdout.split('ruby ')[1].split('p')[0].to_f
  end
end
