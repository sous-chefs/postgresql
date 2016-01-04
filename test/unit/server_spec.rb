require 'spec_helper'

describe 'postgresql::server' do
  platforms = {
    'ubuntu' => {
      'versions' => ['12.04', '14.04']
     },
    'centos' => {
       'versions' => ['6.4', '7.0']
     },
    'redhat' => {
       'versions' => ['6.5', '7.0']
     },
    'debian' => {
       'versions' => ['7.6']
     },
    'opensuse' => {
      'versions' => ['13.1', '13.2']
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

        before do
          stub_command(/ls \/.*\/recovery.conf/).and_return(false)
        end

        it 'runs no tests' do
          expect(chef_run)
        end
      end
    end
  end
end
