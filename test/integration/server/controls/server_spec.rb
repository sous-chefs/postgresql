# frozen_string_literal: true
include_controls 'client'

describe service('postgresql') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

sql = postgres_session('postgres', 'iloverandompasswordsbutthiswilldo')

describe sql.query('SELECT * FROM pg_shadow WHERE passwd IS NULL;') do
  its(:lines) { should eq ['(0 rows)'] }
end
