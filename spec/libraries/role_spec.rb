require 'spec_helper'
require_relative '../../libraries/sql/role'

# Mock the dependencies for testing
module PostgreSQL
  module Cookbook
    module Utils
      def nil_or_empty?(value)
        value.nil? || value.empty?
      end
    end

    module SqlHelpers
      module Connection
      end
    end
  end
end

class Utils
end

describe 'PostgreSQL::Cookbook::SqlHelpers::Role' do
  let(:test_class) do
    Class.new do
      include PostgreSQL::Cookbook::SqlHelpers::Role
      include PostgreSQL::Cookbook::Utils
    end
  end

  let(:instance) { test_class.new }

  describe '#escape_password_for_sql' do
    context 'with SCRAM-SHA-256 passwords' do
      let(:scram_password) { 'SCRAM-SHA-256$4096:27klCUc487uwvJVGKI5YNA==$6K2Y+S3YBlpfRNrLROoO2ulWmnrQoRlGI1GqpNRq0T0=:y4esBVjK/hMtxDB5aWN4ynS1SnQcT1TFTqV0J/snls4=' }

      it 'escapes dollar signs in SCRAM-SHA-256 passwords' do
        result = instance.send(:escape_password_for_sql, scram_password)
        expect(result).to eq('SCRAM-SHA-256\$4096:27klCUc487uwvJVGKI5YNA==\$6K2Y+S3YBlpfRNrLROoO2ulWmnrQoRlGI1GqpNRq0T0=:y4esBVjK/hMtxDB5aWN4ynS1SnQcT1TFTqV0J/snls4=')
      end

      it 'handles SCRAM-SHA-256 passwords with multiple dollar signs' do
        password = 'SCRAM-SHA-256$1024:salt$key1$key2'
        result = instance.send(:escape_password_for_sql, password)
        expect(result).to eq('SCRAM-SHA-256\$1024:salt\$key1\$key2')
      end
    end

    context 'with non-SCRAM passwords' do
      it 'does not modify MD5 passwords' do
        md5_password = 'md5c5e1324c052bd9e8471c44a3d2bda0c8'
        result = instance.send(:escape_password_for_sql, md5_password)
        expect(result).to eq(md5_password)
      end

      it 'does not modify plain text passwords' do
        plain_password = 'my$plain$password'
        result = instance.send(:escape_password_for_sql, plain_password)
        expect(result).to eq(plain_password)
      end

      it 'does not modify other hash types' do
        other_hash = 'sha256$somehash$value'
        result = instance.send(:escape_password_for_sql, other_hash)
        expect(result).to eq(other_hash)
      end
    end

    context 'with edge cases' do
      it 'handles nil passwords' do
        result = instance.send(:escape_password_for_sql, nil)
        expect(result).to be_nil
      end

      it 'handles empty passwords' do
        result = instance.send(:escape_password_for_sql, '')
        expect(result).to eq('')
      end

      it 'handles passwords that start with SCRAM-SHA-256 but have no dollar signs' do
        password = 'SCRAM-SHA-256-invalid'
        result = instance.send(:escape_password_for_sql, password)
        expect(result).to eq(password)
      end
    end
  end
end