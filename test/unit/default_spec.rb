require 'spec_helper'

describe 'postgresql::default' do
  platforms = {
    'ubuntu' => {
      'versions' => ['12.04', '14.04', '16.04']
    },
    'centos' => {
      'versions' => ['6.8', '7.0']
    },
    'redhat' => {
      'versions' => ['6.5', '7.0']
    },
    'debian' => {
      'versions' => ['7.11']
    },
    'opensuse' => {
      'versions' => ['13.1', '13.2']
    }
  }

  platforms.each do |platform, config|
    config['versions'].each do |version|
      context "on #{platform} #{version}" do
        let(:chef_run) do
          ChefSpec::ServerRunner.new(
            platform: platform.to_s,
            version: version.to_s
          ) do |node|
            node.normal['postgresql']['password']['postgres'] = 'ilikewaffles'
          end.converge(described_recipe)
        end

        it 'runs no tests' do
          expect(chef_run)
        end
      end
    end
  end
end
