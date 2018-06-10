require 'spec_helper'
require_relative '../../libraries/helpers.rb'

RSpec.describe PostgresqlCookbook::Helpers do
  class DummyClass < Chef::Node
    include PostgresqlCookbook::Helpers
  end
  subject { DummyClass.new }

  describe '#data_dir(version)' do
    before do
      allow(subject).to receive(:[]).with('platform_family').and_return(platform_family)
    end

    let(:pg_version) { '9.6' }

    context 'with rhel family and Postgres 9.6' do
      let(:platform_family) { 'rhel' }

      it 'returns the correct path' do
        expect(subject.data_dir(pg_version)).to eq '/var/lib/pgsql/9.6/data'
      end
    end

    context 'with debian family and Postgres 9.6' do
      let(:platform_family) { 'debian' }

      it 'returns the correct path' do
        expect(subject.data_dir(pg_version)).to eq '/var/lib/postgresql/9.6/main'
      end
    end
  end

  describe '#conf_dir(version)' do
    before do
      allow(subject).to receive(:[]).with('platform_family').and_return(platform_family)
    end

    let(:pg_version) { '9.6' }

    context 'with rhel family and Postgres 9.6' do
      let(:platform_family) { 'rhel' }

      it 'returns the correct path' do
        expect(subject.conf_dir(pg_version)).to eq '/var/lib/pgsql/9.6/data'
      end
    end

    context 'with debian family and Postgres 9.6' do
      let(:platform_family) { 'debian' }

      it 'returns the correct path' do
        expect(subject.conf_dir(pg_version)).to eq '/etc/postgresql/9.6/main'
      end
    end
  end

  describe '#platform_service_name(version)' do
    before do
      allow(subject).to receive(:[]).with('platform_family').and_return(platform_family)
    end

    let(:pg_version) { '9.6' }

    context 'with rhel family and Postgres 9.6' do
      let(:platform_family) { 'rhel' }

      it 'returns the correct service name' do
        expect(subject.platform_service_name(pg_version)).to eq 'postgresql-9.6'
      end
    end

    context 'with debian family and Postgres 9.6' do
      let(:platform_family) { 'debian' }

      it 'returns the correct service name' do
        expect(subject.platform_service_name(pg_version)).to eq 'postgresql'
      end
    end
  end

  describe '#psql_command_string' do
    before do
      @new_resource = double(database: 'db_foo',
                             user: 'postgres',
                             host: 'localhost',
                             port: '5432'
                            )
      @query = 'THIS IS A COMMAND STRING'
    end

    it 'returns a full command string given all the parameters' do
      grep_for = 'FOO'
      result = 'psql -c "THIS IS A COMMAND STRING" -d db_foo -U postgres --host localhost --port 5432 | grep FOO'

      expect(subject.psql_command_string(@new_resource, @query, grep_for)).to eq(result)
    end

    it 'returns a command without grep' do
      result = 'psql -c "THIS IS A COMMAND STRING" -d db_foo -U postgres --host localhost --port 5432'

      expect(subject.psql_command_string(@new_resource, @query)).to eq(result)
    end

    it 'Allow us to connect to postgresql without specifying the database name' do
      new_resource = double(database: 'test_1234',
                            user: 'postgres',
                            port: '5432',
                            host: nil
                           )
      res = double(
        user: new_resource.user,
        port: new_resource.port,
        database: nil,
        host: nil
      )

      db_query = 'SELECT datname from pg_database WHERE datname=\'test_1234\''
      grep_for = 'test_1234'

      result = 'psql -c "SELECT datname from pg_database WHERE datname=\'test_1234\'" -U postgres --port 5432 | grep test_1234'

      expect(subject.psql_command_string(res, db_query, grep_for.to_s)).to eq(result)
    end

    it 'Allows new_resource.database to be nil or not set' do
      new_resource = double(database: nil,
                            user: 'postgres',
                            port: '5432',
                            host: '127.0.0.1'
                           )
      db_query = 'SELECT datname from pg_database WHERE datname=\'test_1234\''
      result = 'psql -c "SELECT datname from pg_database WHERE datname=\'test_1234\'" -U postgres --host 127.0.0.1 --port 5432'

      expect(subject.psql_command_string(new_resource, db_query)).to eq(result)
    end
  end

  describe '#role_sql' do
    before do
      @new_resource = double(
        create_user: 'sous_chef',
        superuser: true,
        password: '67890',
        createdb: nil,
        sensitive: false,
        createrole: nil,
        inherit: nil,
        replication: nil,
        login: true,
        encrypted_password: nil,
        valid_until: nil
      )
    end
    it 'Should return a correctly formatted role creation string' do
      result = "sous_chef WITH SUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT NOREPLICATION LOGIN PASSWORD '67890'"
      expect(subject.role_sql(@new_resource)).to eq result
    end
  end
end
