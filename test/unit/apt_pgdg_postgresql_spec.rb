require 'spec_helper'

describe 'postgresql::default' do
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
          node.set['postgresql']['enable_pgdg_apt'] = true
          end.converge(described_recipe)
        }

        it 'includes the apt cookbook' do
          expect(chef_run).to include_recipe('apt::default')
        end

        it 'removes the Pitti PPA sources.list' do
          expect(chef_run).to delete_file('/etc/apt/sources.list.d/pitti-postgresql-ppa')
        end

        it 'creates the PGDG apt sources.list' do
          expect(chef_run).to add_apt_repository('apt.postgresql.org').with(uri:'http://apt.postgresql.org/pub/repos/apt',
                                                                            distribution: "#{chef_run.node['postgresql']['pgdg']['release_apt_codename']}-pgdg",
                                                                            components: ['main', chef_run.node['postgresql']['version']],
                                                                            key: 'https://www.postgresql.org/media/keys/ACCC4CF8.asc')
        end
      end
    end
  end
end
