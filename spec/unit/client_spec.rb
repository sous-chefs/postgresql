# frozen_string_literal: true
require 'spec_helper'

describe 'Client installation' do
  platforms = {
    'ubuntu' => {
      'versions' => ['14.04', '16.04'],
    },
    'centos' => {
      'versions' => ['6.9', '7.3.1611'],
    },
    'debian' => {
      'versions' => ['7.11', '8.8'],
    },
    'opensuse' => {
      'versions' => ['42.2'],
    },
  }

  platforms.each do |platform, config|
    config['versions'].each do |version|
      context "on #{platform} #{version}" do
        let(:chef_run) do
          ChefSpec::SoloRunner.new(
            platform: platform.to_s,
            version: version.to_s
          ) do |node|
            node.default['postgresql']['password']['postgres'] = 'ilikewaffles'
          end.converge('postgresql::client')
        end

        it 'converges successfully' do
          expect { :chef_run }.to_not raise_error
        end
      end
    end
  end
end
