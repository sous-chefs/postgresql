require 'spec_helper'
require_relative '../../libraries/resource_helpers.rb'

RSpec.describe PostgresqlCookbook::Helpers do
  class DummyClass < Chef::Node
    include PostgresqlCookbook::Helpers
  end
  subject { DummyClass.new }

  describe '#data_dir' do
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
end
