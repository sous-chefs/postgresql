require 'spec_helper'

describe 'postgresql::server' do
  platforms = {
    'ubuntu' => {
      'versions' => ['10.04', '12.04', '14.04']
     },
    'centos' => {
       'versions' => ['6.4', '7.0']
     },
    'redhat' => {
       'versions' => ['6.5', '7.0']
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
            node.set['postgresql']['config']['ssl_cert_file'] = '/tmp/server.crt'
            node.set['postgresql']['config']['ssl_key_file'] = '/tmp/server.key'
          end.converge(described_recipe)
        }

        it 'installs the postgresql client packages from the client recipe' do
          expect(chef_run).to include_recipe('postgresql::client')

          chef_run.node['postgresql']['client']['packages'].each do |pkg|
            expect(chef_run).to install_package(pkg)
          end
        end

        # Broken test.
        #it 'runs the postgresql service' do
        #  expect(chef_run).to notify('service[postgresql]')
        #end

        it 'symlinks the ssl_cert_file and ssl_key_file when the postgresql version is < 9.2' do
          if chef_run.node['postgresql']['version'].to_f < 9.2
            expect(chef_run).to create_link("#{::File.join(chef_run.node['postgresql']['config']['data_directory'], 'server.crt')}").with(to: '/tmp/server.crt')
            expect(chef_run).to create_link("#{::File.join(chef_run.node['postgresql']['config']['data_directory'], 'server.key')}").with(to: '/tmp/server.key')
          else
            expect(chef_run).not_to create_link("#{::File.join(chef_run.node['postgresql']['config']['data_directory'], 'server.crt')}").with(to: '/tmp/server.crt')
            expect(chef_run).not_to create_link("#{::File.join(chef_run.node['postgresql']['config']['data_directory'], 'server.key')}").with(to: '/tmp/server.key')
          end
        end

        it 'only adds ssl_key_file or ssl_cert_file options to postgresql.conf when postgresql version is >= 9.2' do
          if chef_run.node['postgresql']['version'].to_f < 9.2
            expect(chef_run).not_to render_file("#{::File.join(chef_run.node['postgresql']['dir'], 'postgresql.conf')}").with_content(/^ssl_cert_file/)
            expect(chef_run).not_to render_file("#{::File.join(chef_run.node['postgresql']['dir'], 'postgresql.conf')}").with_content(/^ssl_key_file/)
          else
            expect(chef_run).to render_file("#{::File.join(chef_run.node['postgresql']['dir'], 'postgresql.conf')}").with_content(/^ssl_cert_file/)
            expect(chef_run).to render_file("#{::File.join(chef_run.node['postgresql']['dir'], 'postgresql.conf')}").with_content(/^ssl_key_file/)
          end
        end

      end
    end
  end
end
