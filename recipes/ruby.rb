# frozen_string_literal: false
#
# Cookbook:: postgresql
# Recipe:: ruby
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

# Load the pgdgrepo_rpm_info method from libraries/default.rb
::Chef::Recipe.send(:include, Opscode::PostgresqlHelpers)

begin
  require 'pg'
rescue LoadError
  if platform_family?('debian')
    e = apt_update 'update' do
      action :nothing
    end
    e.run_action(:update)
  end

  node.override['build-essential']['compile_time'] = true
  include_recipe 'build-essential'

  if node['postgresql']['enable_pgdg_yum'] && platform_family?('rhel', 'fedora')
    include_recipe 'postgresql::yum_pgdg_postgresql'

    rpm_platform = node['platform']
    rpm_platform_version = node['platform_version'].to_i.to_s
    arch = node['kernel']['machine']

    resources("remote_file[#{Chef::Config[:file_cache_path]}/#{node['postgresql']['pgdg']['repo_rpm_url'][node['postgresql']['version']][rpm_platform][rpm_platform_version][arch]['package']}]").run_action(:create)
    resources("package[#{node['postgresql']['pgdg']['repo_rpm_url'][node['postgresql']['version']][rpm_platform][rpm_platform_version][arch]['package']}]").run_action(:install)

    ENV['PATH'] = "/usr/pgsql-#{node['postgresql']['version']}/bin:#{ENV['PATH']}"
  end

  if node['postgresql']['enable_pgdg_apt'] && platform_family?('debian')
    include_recipe 'postgresql::apt_pgdg_postgresql'
    resources('apt_repository[apt.postgresql.org]').run_action(:add)
  end

  include_recipe 'postgresql::client'

  package node['postgresql']['client']['packages'] do
    action :nothing
  end.run_action(:install)

  begin
    chef_gem 'pg' do
      compile_time true
      version node['postgresql']['pg_gem']['version'] if node['postgresql']['pg_gem']['version']
    end
  rescue Gem::Installer::ExtensionBuildError, Mixlib::ShellOut::ShellCommandFailed => e
    # Are we an omnibus install?
    raise if RbConfig.ruby.scan(/(chef|opscode)/).empty?
    # Still here, must be omnibus. Lets make this thing install!
    Chef::Log.warn 'Failed to properly build pg gem. Forcing properly linking and retrying (omnibus fix)'
    gem_dir = e.message.scan(/will remain installed in ([^ ]+)/).flatten.first
    raise unless gem_dir
    gem_name = File.basename(gem_dir)
    ext_dir = File.join(gem_dir, 'ext')
    gem_exec = File.join(File.dirname(RbConfig.ruby), 'gem')
    new_content = <<-EOS
require 'rbconfig'
%w(
configure_args
LIBRUBYARG_SHARED
LIBRUBYARG_STATIC
LIBRUBYARG
LDFLAGS
).each do |key|
  RbConfig::CONFIG[key].gsub!(/-Wl[^ ]+( ?\\/[^ ]+)?/, '')
  RbConfig::MAKEFILE_CONFIG[key].gsub!(/-Wl[^ ]+( ?\\/[^ ]+)?/, '')
end
RbConfig::CONFIG['RPATHFLAG'] = ''
RbConfig::MAKEFILE_CONFIG['RPATHFLAG'] = ''
EOS
    new_content << File.read(extconf_path = File.join(ext_dir, 'extconf.rb'))
    File.open(extconf_path, 'w') do |file|
      file.write(new_content)
    end

    lib_builder = execute 'generate pg gem Makefile' do
      # [COOK-3490] pg gem install requires full path on RHEL
      command "PATH=$PATH:/usr/pgsql-#{node['postgresql']['version']}/bin #{RbConfig.ruby} extconf.rb"
      cwd ext_dir
      action :nothing
    end
    lib_builder.run_action(:run)

    lib_maker = execute 'make pg gem lib' do
      command 'make'
      cwd ext_dir
      action :nothing
    end
    lib_maker.run_action(:run)

    lib_installer = execute 'install pg gem lib' do
      command 'make install'
      cwd ext_dir
      action :nothing
    end
    lib_installer.run_action(:run)

    spec_installer = execute 'install pg spec' do
      command "#{gem_exec} spec ./cache/#{gem_name}.gem --ruby > ./specifications/#{gem_name}.gemspec"
      cwd File.join(gem_dir, '..', '..')
      action :nothing
    end
    spec_installer.run_action(:run)

    Chef::Log.warn 'Installation of pg gem successful!'
  end
end
