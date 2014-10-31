require 'spec_helper'

describe 'postgresql::server_debian' do
  platforms = {
    'ubuntu' => {
      'versions' => ['10.04', '12.04', '14.04']
     },
    'debian' => {
       'versions' => ['7.6']
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

        it 'installs the server packages' do
          chef_run.node['postgresql']['server']['packages'].each do |pg_pack|
            expect(chef_run).to install_package(pg_pack)
          end
        end

        it 'registers the postgresql service' do
          expect(chef_run).to enable_service('postgresql').with(service_name: chef_run.node['postgresql']['server']['service_name'])
          expect(chef_run).to start_service('postgresql')
        end

      end
    end
  end
end

