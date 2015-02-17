require 'spec_helper'

describe 'debian::postgresql::server' do
  let(:chef_application) do
    double('Chef::Application',fatal!:false);
  end
  let(:chef_run) do
    runner = ChefSpec::Runner.new(
                                   platform: 'debian', version: '7.4'
                                 ) do |node|
      node.automatic['memory']['total'] = '2048kB'
      node.automatic['ipaddress'] = '1.1.1.1'
      node.set['postgresql']['version'] = '9.1'
      node.set['postgresql']['password']['postgres'] = 'password'
    end
    runner.converge('postgresql::server')
  end
  before do
    stub_const('Chef::Application',chef_application)
    allow(File).to receive(:directory?).and_call_original
    allow(File).to receive(:directory?).with('/etc/postgresql/9.1/main').and_return(false)
  end

  it 'Install postgresql 9.1' do
    expect(chef_run).to install_package('postgresql-9.1')
  end

  it 'Install postgresql 9.1 client' do
    expect(chef_run).to install_package('postgresql-client-9.1')
  end

  it 'Install postgresql 9.1 dev files' do
    expect(chef_run).to install_package('libpq-dev')
  end

  it 'Enable and start service postgresql' do
    expect(chef_run).to enable_service('postgresql')
    expect(chef_run).to start_service('postgresql')
  end

  it 'Create configuration files' do
    expect(chef_run).to create_template('/etc/postgresql/9.1/main/postgresql.conf')
    expect(chef_run).to create_template('/etc/postgresql/9.1/main/pg_hba.conf')
  end

  it 'Assign Postgres Password' do
    expect(chef_run).to run_bash('assign-postgres-password')
  end

  it 'Launch Cluster Creation' do
    expect(chef_run).to run_execute('Set locale and Create cluster')
  end

  context 'Directory /etc/postgresql/9.1/main exist' do
    before do
      allow(File).to receive(:directory?).and_call_original
      allow(File).to receive(:directory?).with('/etc/postgresql/9.1/main').and_return(true)
    end

    it 'Don t launch Cluster Creation' do
      expect(chef_run).to_not run_execute('Set locale and Create cluster')
    end
  end
end
