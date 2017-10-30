# frozen_string_literal: false
#
# Cookbook:: postgresql
# Resource:: pg
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
property :version, [String, nil], default: '0.21.0'
property :setup_repo, [true, false], default: true

action :install do
  postgresql_repository 'Add downloads.postgresql.org repository' do
    only_if { new_resource.setup_repo }
    action :nothing
  end.run_action :add

  package 'Install dependencies' do
    case node[:platform_family]
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

  begin
      chef_gem 'pg' do
        compile_time true
        version new_resource.version
      end
    rescue Gem::Installer::ExtensionBuildError, Mixlib::ShellOut::ShellCommandFailed => e
      build_essential 'for debian' do
        compile_time true
      end

      # Are we an omnibus install?
      raise if RbConfig.ruby.scan(/(chef|opscode)/).empty?
      # Still here, must be omnibus. Lets make this thing install!
      Chef::Log.warn 'Failed to properly build pg gem. Forcing properly linking and retrying (omnibus fix)'
      gem_dir = e.message.scan(/will remain installed in ([^ ]+)/).flatten.first
      raise unless gem_dir
      gem_name = ::File.basename(gem_dir)
      ext_dir = ::File.join(gem_dir, 'ext')
      gem_exec = ::File.join(::File.dirname(RbConfig.ruby), 'gem')
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
      new_content << ::File.read(extconf_path = ::File.join(ext_dir, 'extconf.rb'))
      ::File.open(extconf_path, 'w') do |file|
        file.write(new_content)
      end

      lib_builder = execute 'generate pg gem Makefile' do
        # [COOK-3490] pg gem install requires full path on RHEL

        command "PATH=$PATH:/usr/pgsql-#{new_resource.client_version}/bin #{RbConfig.ruby} extconf.rb"
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
        cwd ::File.join(gem_dir, '..', '..')
        action :nothing
      end
      spec_installer.run_action(:run)

      Chef::Log.warn 'Installation of pg gem successful!'
    end
end
