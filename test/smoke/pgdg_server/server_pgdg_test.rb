# # encoding: utf-8

# Inspec test for recipe postgresql::server_pgdg

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

describe service('postgresql-9.4') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

sql = postgres_session('postgres', 'iloverandompasswordsbutthiswilldo')

describe sql.query('SELECT * FROM pg_shadow WHERE passwd IS NULL;') do
  its(:lines) { should eq ['(0 rows)'] }
end
