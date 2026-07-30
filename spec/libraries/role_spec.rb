require 'spec_helper'
require_relative '../../libraries/sql/role'

RSpec.describe PostgreSQL::Cookbook::SqlHelpers::Role do
  subject(:helper) do
    Class.new do
      include PostgreSQL::Cookbook::SqlHelpers::Role
    end.new
  end

  let(:pg_client) { double('PG::Connection') }

  before do
    allow(helper).to receive(:pg_client).and_return(pg_client)
  end

  describe '#role_password_sql' do
    it 'quotes a SCRAM-SHA-256 verifier without modifying dollar signs' do
      verifier = 'SCRAM-SHA-256$4096:salt$stored_key:server_key'
      resource = double(encrypted_password: verifier, unencrypted_password: nil)

      expect(pg_client).to receive(:escape_literal).with(verifier).and_return("'#{verifier}'")

      expect(helper.send(:role_password_sql, resource)).to eq("ENCRYPTED PASSWORD '#{verifier}'")
    end

    it 'uses connection-aware quoting for a plaintext password' do
      password = "don't interpolate me"
      resource = double(encrypted_password: nil, unencrypted_password: password)

      expect(pg_client).to receive(:escape_literal).with(password).and_return("'don''t interpolate me'")

      expect(helper.send(:role_password_sql, resource)).to eq("PASSWORD 'don''t interpolate me'")
    end

    it 'clears the password when neither password property is set' do
      resource = double(encrypted_password: nil, unencrypted_password: nil)

      expect(helper.send(:role_password_sql, resource)).to eq('PASSWORD NULL')
    end
  end
end
