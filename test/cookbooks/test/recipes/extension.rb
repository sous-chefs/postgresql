postgresql_repository 'install' do
  version '9.6'
end

postgresql_server_install 'package' do
  version '9.6'
end

postgresql_extension 'openfts' do
  database  'test_1'
end

def psql(q)
  "psql -d test_1 <<< '\\set ON_ERROR_STOP on\n#{q};'"
end

query = "SELECT 'installed' FROM pg_extension WHERE extname = 'openfts';"

check_extension = psql(query)

describe bash("#{check_extension}") do
  its('stdout') { should match /openfts/ }
  its('exit_status') { should eq 0 }
end
