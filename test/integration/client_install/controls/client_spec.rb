pg_ver = input('pg_ver')

control 'postgresql-client-install' do
  impact 1.0
  desc 'These tests ensure a postgresql client installed correctly'

  describe command('/usr/bin/psql -V') do
    its('stdout') { should match(/psql \(PostgreSQL\) #{pg_ver}.\d/) }
    its('exit_status') { should eq 0 }
  end
end
