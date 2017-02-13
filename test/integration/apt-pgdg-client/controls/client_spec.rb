# frozen_string_literal: true
pgdg_version = attribute('pgdg_version', default: '9.4', description: 'PostgreSQL installed version by default')

describe command('/usr/bin/psql --help') do
  its('exit_status') { should eq 0 }
end

describe command('/usr/bin/psql -V') do
  its('stdout') { should match(/psql \(PostgreSQL\) #{pgdg_version}/) }
  its('exit_status') { should eq 0 }
end
