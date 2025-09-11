require 'spec_helper'
require_relative '../../libraries/ident'

RSpec.describe PostgreSQL::Cookbook::IdentHelpers::PgIdent::PgIdentFile do
  let(:ident_file) { described_class.new }

  describe '#add' do
    let(:entry1) do
      PostgreSQL::Cookbook::IdentHelpers::PgIdent::PgIdentFileEntry.new(
        map_name: 'testmap',
        system_username: 'user1',
        database_username: 'dbuser1'
      )
    end

    let(:entry2) do
      PostgreSQL::Cookbook::IdentHelpers::PgIdent::PgIdentFileEntry.new(
        map_name: 'testmap',
        system_username: 'user2',
        database_username: 'dbuser2'
      )
    end

    let(:duplicate_entry) do
      PostgreSQL::Cookbook::IdentHelpers::PgIdent::PgIdentFileEntry.new(
        map_name: 'testmap',
        system_username: 'user1',
        database_username: 'dbuser1'
      )
    end

    it 'allows multiple entries with the same map_name but different system/database usernames' do
      result1 = ident_file.add(entry1)
      result2 = ident_file.add(entry2)

      expect(result1).to be_truthy
      expect(result2).to be_truthy
      expect(ident_file.entries.size).to eq(2)
    end

    it 'prevents adding duplicate entries' do
      ident_file.add(entry1)
      result = ident_file.add(duplicate_entry)

      expect(result).to be_falsy
      expect(ident_file.entries.size).to eq(1)
    end
  end

  describe '#entry' do
    let(:entry1) do
      PostgreSQL::Cookbook::IdentHelpers::PgIdent::PgIdentFileEntry.new(
        map_name: 'testmap',
        system_username: 'user1',
        database_username: 'dbuser1'
      )
    end

    let(:entry2) do
      PostgreSQL::Cookbook::IdentHelpers::PgIdent::PgIdentFileEntry.new(
        map_name: 'testmap',
        system_username: 'user2',
        database_username: 'dbuser2'
      )
    end

    before do
      ident_file.add(entry1)
      ident_file.add(entry2)
    end

    it 'returns specific entry when all parameters are provided' do
      result = ident_file.entry('testmap', 'user1', 'dbuser1')
      expect(result).to eq(entry1)

      result = ident_file.entry('testmap', 'user2', 'dbuser2')
      expect(result).to eq(entry2)
    end

    it 'returns first entry when only map_name is provided and multiple entries exist' do
      result = ident_file.entry('testmap')
      expect(result).to be_a(PostgreSQL::Cookbook::IdentHelpers::PgIdent::PgIdentFileEntry)
      expect(result.map_name).to eq('testmap')
    end

    it 'returns nil when no matching entry is found' do
      result = ident_file.entry('testmap', 'nonexistent', 'user')
      expect(result).to be_nil
    end
  end

  describe '#include?' do
    let(:entry) do
      PostgreSQL::Cookbook::IdentHelpers::PgIdent::PgIdentFileEntry.new(
        map_name: 'testmap',
        system_username: 'user1',
        database_username: 'dbuser1'
      )
    end

    let(:different_entry) do
      PostgreSQL::Cookbook::IdentHelpers::PgIdent::PgIdentFileEntry.new(
        map_name: 'testmap',
        system_username: 'user2',
        database_username: 'dbuser2'
      )
    end

    it 'returns true for existing entries' do
      ident_file.add(entry)
      expect(ident_file.include?(entry)).to be_truthy
    end

    it 'returns false for non-existing entries' do
      ident_file.add(entry)
      expect(ident_file.include?(different_entry)).to be_falsy
    end
  end

  describe 'issue scenario' do
    # Test the specific scenario from GitHub issue #787
    it 'allows multiple mappings per map name as described in the issue' do
      entry1 = PostgreSQL::Cookbook::IdentHelpers::PgIdent::PgIdentFileEntry.new(
        map_name: 'someuser_postgres',
        system_username: 'someuser',
        database_username: 'postgres'
      )

      entry2 = PostgreSQL::Cookbook::IdentHelpers::PgIdent::PgIdentFileEntry.new(
        map_name: 'someuser_postgres',
        system_username: 'postgres',
        database_username: 'postgres'
      )

      result1 = ident_file.add(entry1)
      result2 = ident_file.add(entry2)

      expect(result1).to be_truthy
      expect(result2).to be_truthy
      expect(ident_file.entries.size).to eq(2)

      # Verify both entries can be retrieved
      retrieved1 = ident_file.entry('someuser_postgres', 'someuser', 'postgres')
      retrieved2 = ident_file.entry('someuser_postgres', 'postgres', 'postgres')

      expect(retrieved1).to eq(entry1)
      expect(retrieved2).to eq(entry2)
    end
  end
end

RSpec.describe PostgreSQL::Cookbook::IdentHelpers::PgIdent::PgIdentFileEntry do
  describe '#eql?' do
    let(:entry1) do
      described_class.new(
        map_name: 'testmap',
        system_username: 'user1',
        database_username: 'dbuser1'
      )
    end

    let(:entry2) do
      described_class.new(
        map_name: 'testmap',
        system_username: 'user1',
        database_username: 'dbuser1'
      )
    end

    let(:entry3) do
      described_class.new(
        map_name: 'testmap',
        system_username: 'user2',
        database_username: 'dbuser1'
      )
    end

    it 'returns true for entries with same map_name, system_username, and database_username' do
      expect(entry1.eql?(entry2)).to be_truthy
    end

    it 'returns false for entries with different system_username' do
      expect(entry1.eql?(entry3)).to be_falsy
    end
  end
end