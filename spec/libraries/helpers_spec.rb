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

      context "with rhel family and Postgres #{pg_version} from repo" do
        let(:platform_family) { 'rhel' }

        it 'returns the correct path' do
          expect(subject.data_dir(version: pg_version, source: :repo)).to eq "/var/lib/pgsql/#{pg_version}/data"
        end
      end

      context "with rhel family and Postgres #{pg_version} from os" do
        let(:platform_family) { 'rhel' }

        it 'returns the correct path' do
          expect(subject.data_dir(version: pg_version, source: :os)).to eq '/var/lib/pgsql/data'
        end
      end

      context "with debian family and Postgres #{pg_version} from repo" do
        let(:platform_family) { 'debian' }

        it 'returns the correct path' do
          expect(subject.data_dir(version: pg_version, source: :repo)).to eq "/var/lib/postgresql/#{pg_version}/main"
        end
      end

      context "with debian family and Postgres #{pg_version} from os" do
        let(:platform_family) { 'debian' }

        it 'returns the correct path' do
          expect(subject.data_dir(version: pg_version, source: :os)).to eq "/var/lib/postgresql/#{pg_version}/main"
        end
      end
    end

    describe '#conf_dir(version)' do
      before do
        allow(subject).to receive(:[]).with('platform_family').and_return(platform_family)
      end

      context "with rhel family and Postgres #{pg_version} from repo" do
        let(:platform_family) { 'rhel' }

        it 'returns the correct path' do
          expect(subject.conf_dir(version: pg_version, source: :repo)).to eq "/var/lib/pgsql/#{pg_version}/data"
        end
      end

      context "with rhel family and Postgres #{pg_version} from os" do
        let(:platform_family) { 'rhel' }

        it 'returns the correct path' do
          expect(subject.conf_dir(version: pg_version, source: :os)).to eq '/var/lib/pgsql/data'
        end
      end

      context "with debian family and Postgres #{pg_version} from repo" do
        let(:platform_family) { 'debian' }

        it 'returns the correct path' do
          expect(subject.conf_dir(version: pg_version, source: :repo)).to eq "/etc/postgresql/#{pg_version}/main"
        end
      end

      context "with debian family and Postgres #{pg_version} from os" do
        let(:platform_family) { 'debian' }

        it 'returns the correct path' do
          expect(subject.conf_dir(version: pg_version, source: :os)).to eq "/etc/postgresql/#{pg_version}/main"
        end
      end
    end

    describe '#default_platform_service_name(version)' do
      before do
        allow(subject).to receive(:[]).with(:platform_family).and_return(platform_family)
      end

      context "with rhel family and Postgres #{pg_version} from repo" do
        let(:platform_family) { 'rhel' }

        it 'returns the correct service name' do
          expect(subject.default_platform_service_name(version: pg_version, source: :repo)).to eq "postgresql-#{pg_version}"
        end
      end

      context "with rhel family and Postgres #{pg_version} from os" do
        let(:platform_family) { 'rhel' }

        it 'returns the correct service name' do
          expect(subject.default_platform_service_name(version: pg_version, source: :os)).to eq 'postgresql'
        end
      end

      context "with debian family and Postgres #{pg_version} from repo" do
        let(:platform_family) { 'debian' }

        it 'returns the correct service name' do
          expect(subject.default_platform_service_name(version: pg_version, source: :repo)).to eq 'postgresql'
        end
      end

      context "with debian family and Postgres #{pg_version} from os" do
        let(:platform_family) { 'debian' }

        it 'returns the correct service name' do
          expect(subject.default_platform_service_name(version: pg_version, source: :os)).to eq 'postgresql'
        end
      end
    end
  end

  describe '#dnf_module_platform?' do
    before do
      allow(subject).to receive(:platform_family?).and_return(false)
      allow(subject).to receive(:platform_family?).with('rhel').and_return(true)
    end

    it 'returns false on RHEL 7' do
      allow(subject).to receive(:[]).with('platform_version').and_return('7.9')

      expect(subject.dnf_module_platform?).to be false
    end

    it 'returns true on RHEL 8' do
      allow(subject).to receive(:[]).with('platform_version').and_return('8.9')

      expect(subject.dnf_module_platform?).to be true
    end

    it 'returns true on RHEL 9' do
      allow(subject).to receive(:[]).with('platform_version').and_return('9.4')

      expect(subject.dnf_module_platform?).to be true
    end

    it 'returns false on RHEL 10' do
      allow(subject).to receive(:[]).with('platform_version').and_return('10.0')

      expect(subject.dnf_module_platform?).to be false
    end
  end
end
