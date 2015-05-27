require 'spec_helper'

describe 'postgresql::server_redhat' do
  platforms = {
    'centos' => {
       'versions' => ['6.4', '7.0']
     },
    'redhat' => {
       'versions' => ['6.5', '7.0']
     },
    'fedora' => {
       'versions' => ['18', '19', '20']
     },
    'suse' => {
       'versions' => ['11.1', '11.2', '11.3', '12.0']
     }
  }


  platforms.each do |platform, config|
    config['versions'].each do |version|
      context "on #{platform} #{version}" do
        let(:chef_run) {
          ChefSpec::SoloRunner.new(
            :platform => platform.to_s,
            :version => version.to_s
          ) do |node|
            node.set['postgresql']['password']['postgres'] = 'ilikewaffles'
          end.converge(described_recipe)
        }

        it 'includes the client recipe' do
          expect(chef_run).to include_recipe('postgresql::client')
        end

        it 'creates the group postgres' do
          expect(chef_run).to create_group('postgres').with(gid: 26)
        end

        it 'creates the user postgres' do
          expect(chef_run).to create_user('postgres').with(uid: 26, gid: 'postgres', shell: '/bin/bash', home: '/var/lib/pgsql', system: true)
        end

        it 'creates the postgres dir' do
          expect(chef_run).to create_directory(chef_run.node['postgresql']['dir']).with(owner: 'postgres', group: 'postgres', recursive: true)
        end

        it 'installs the server packages' do
          chef_run.node['postgresql']['server']['packages'].each do |pg_pack|
            expect(chef_run).to install_package(pg_pack)
          end
        end

        it 'creates the file in /etc/sysconfig/pgsql using the sevice name', :unless => platform == 'fedora' do
            expect(chef_run).to create_directory('/etc/sysconfig/pgsql').with(mode: "0644", recursive: true)
            expect(chef_run).to create_template("/etc/sysconfig/pgsql/#{chef_run.node['postgresql']['server']['service_name']}").with(mode: "0644")
        end

        it 'does not create the dir /etc/sysconfig/pgsql on fedora', :if => platform == 'fedora' do
            expect(chef_run).not_to create_directory('/etc/sysconfig/pgsql')
            expect(chef_run).not_to create_template("/etc/sysconfig/pgsql/#{chef_run.node['postgresql']['server']['service_name']}")
        end

        it 'uses postgresql-setup on fedora', :if => :platform == 'fedora' do
            expect(chef_run).to run_execute("postgresql-setup initdb #{chef_run.node['postgresql']['server']['service_name']}")
        end

        it 'does not use postgresql-setup on when not running on fedora', :unless => platform == 'fedora' do
            expect(chef_run).not_to run_execute("postgresql-setup initdb #{chef_run.node['postgresql']['server']['service_name']}")
        end

        it 'uses the service command on everything except fedora', :unless => platform == 'fedora' do
            expect(chef_run).to run_execute("/sbin/service #{chef_run.node['postgresql']['server']['service_name']} initdb #{chef_run.node['postgresql']['initdb_locale']}")
        end

        it 'does not use the service command on fedora', :if => platform == 'fedora' do
            expect(chef_run).not_to run_execute("/sbin/service #{chef_run.node['postgresql']['server']['service_name']} initdb #{chef_run.node['postgresql']['initdb_locale']}")
        end

        it 'registers the postgresql service' do
          expect(chef_run).to enable_service('postgresql').with(service_name: chef_run.node['postgresql']['server']['service_name'])
          expect(chef_run).to start_service('postgresql')
        end

      end
    end
  end
end

