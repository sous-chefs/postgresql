require 'spec_helper'
require_relative '../../libraries/helpers'

RSpec.describe PostgreSQL::Cookbook::Helpers do
  class DummyClass < Chef::Node
    include PostgreSQL::Cookbook::Helpers
  end
  subject { DummyClass.new }

  %w(11 12 13 14 15).each do |pg_version|
    describe '#data_dir(version)' do
      before do
        allow(subject).to receive(:[]).with('platform_family').and_return(platform_family)
      end

      context "with rhel family and Postgres #{pg_version}" do
        let(:platform_family) { 'rhel' }

        it 'returns the correct path' do
          expect(subject.data_dir(pg_version)).to eq "/var/lib/pgsql/#{pg_version}/data"
        end
      end

      context "with debian family and Postgres #{pg_version}" do
        let(:platform_family) { 'debian' }

        it 'returns the correct path' do
          expect(subject.data_dir(pg_version)).to eq "/var/lib/postgresql/#{pg_version}/main"
        end
      end
    end

    describe '#conf_dir(version)' do
      before do
        allow(subject).to receive(:[]).with('platform_family').and_return(platform_family)
      end

      context "with rhel family and Postgres #{pg_version}" do
        let(:platform_family) { 'rhel' }

        it 'returns the correct path' do
          expect(subject.conf_dir(pg_version)).to eq "/var/lib/pgsql/#{pg_version}/data"
        end
      end

      context "with debian family and Postgres #{pg_version}" do
        let(:platform_family) { 'debian' }

        it 'returns the correct path' do
          expect(subject.conf_dir(pg_version)).to eq "/etc/postgresql/#{pg_version}/main"
        end
      end
    end

    describe '#default_platform_service_name(version)' do
      before do
        allow(subject).to receive(:[]).with(:platform_family).and_return(platform_family)
      end

      context "with rhel family and Postgres #{pg_version}" do
        let(:platform_family) { 'rhel' }

        it 'returns the correct service name' do
          expect(subject.default_platform_service_name(pg_version)).to eq "postgresql-#{pg_version}"
        end
      end

      context "with debian family and Postgres #{pg_version}" do
        let(:platform_family) { 'debian' }

        it 'returns the correct service name' do
          expect(subject.default_platform_service_name(pg_version)).to eq 'postgresql'
        end
      end
    end
  end
end
