control 'postgresql-client-install' do
  impact 1.0
  desc 'These tests ensure a postgresql client installed correctly'

  describe command('/usr/bin/psql -V') do
    its('stdout') { should match(/psql \(PostgreSQL\) [0-9.]+/) }
    its('exit_status') { should eq 0 }
  end
end
