describe command('/usr/bin/psql --help') do
  its('exit_status') { should eq 0 }
end

describe command('/usr/bin/psql -V') do
  its('stdout') { should match(/psql \(PostgreSQL\) 9\.6/) }
  its('exit_status') { should eq 0 }
end
