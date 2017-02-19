# frozen_string_literal: true
require 'spec_helper'

describe 'opensuse::postgresql::server' do
  let(:chef_application) do
    double('Chef::Application', fatal!: false)
  end
  let(:chef_run) do
    runner = ChefSpec::ServerRunner.new(
      platform: 'opensuse', version: '13.1'
    ) do |node|
      node.automatic['memory']['total'] = '2048kB'
      node.automatic['ipaddress'] = '1.1.1.1'
      node.normal['postgresql']['version'] = '9.2'
      node.normal['postgresql']['password']['postgres'] = 'password'
      node.normal['postgresql']['dir'] = '/var/lib/pgsql/data'
      node.normal['postgresql']['conf_dir'] = '/etc/sysconfig/pgsql'
      node.normal['postgresql']['initdb_locale'] = 'UTF-8'
    end
    runner.converge('postgresql::server')
  end
  before do
    stub_const('Chef::Application', chef_application)
    allow(File).to receive(:directory?).and_call_original
    allow(File).to receive(:directory?).with('/etc/sysconfig/pgsql').and_return(false)
    stub_command('ls /var/lib/pgsql/data/recovery.conf').and_return(false)
  end

  it 'Install postgresql 9.2' do
    expect(chef_run).to install_package('postgresql92-server')
  end

  it 'Install postgresql 9.2 client and dev packages' do
    expect(chef_run).to install_package(['postgresql92', 'postgresql92-devel'])
  end

  it 'Enable and start service postgresql' do
    expect(chef_run).to enable_service('postgresql')
    expect(chef_run).to start_service('postgresql')
  end

  it 'Create configuration files' do
    expect(chef_run).to create_template('/var/lib/pgsql/data/postgresql.conf')
    expect(chef_run).to create_template('/var/lib/pgsql/data/pg_hba.conf')
  end

  it 'Assign Postgres Password' do
    expect(chef_run).to run_bash('assign-postgres-password')
  end

  context 'when running as a standby host' do
    it 'does not assign the Postgres password' do
      stub_command('ls /var/lib/pgsql/main/recovery.conf').and_return(false)
      expect(chef_run).to_not run_bash('assign_postgres_password')
    end
  end

  it 'Launch Cluster Creation' do
    expect(chef_run).to run_execute('initdb -d /var/lib/pgsql/data')
  end

  context 'Directory /etc/sysconfig/pgsql exist' do
    before do
      allow(File).to receive(:directory?).and_call_original
      allow(File).to receive(:directory?).with('/etc/sysconfig/pgsql').and_return(true)
    end

    it 'Don\'t launch Cluster Creation' do
      expect(chef_run).to_not run_execute('Set locale and Create cluster')
    end
  end
end
