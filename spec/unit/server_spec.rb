# frozen_string_literal: true
require 'spec_helper'

describe 'postgresql::server' do
  platforms = {
    'ubuntu' => {
      'versions' => ['12.04', '14.04', '16.04'],
    },
    'centos' => {
      'versions' => ['6.8', '7.2.1511'],
    },
    'redhat' => {
      'versions' => ['6.6', '7.2'],
    },
    'debian' => {
      'versions' => ['7.11', '8.6'],
    },
    'opensuse' => {
      'versions' => ['13.2', '42.1'],
    },
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

        before do
          stub_command(/ls \/.*\/recovery.conf/).and_return(false)
        end

        it 'converges successfully' do
          expect { :chef_run }.to_not raise_error
        end
      end
    end
  end
end
