pg_path =
  case os.family
  when 'debian'
    '/usr/lib/postgresql/'
  when 'redhat', 'fedora'
    '/usr/pgsql-'
  end

control 'postgresql-client-multi-install' do
  describe command('/usr/bin/psql -V') do
    its('stdout') { should match(/psql \(PostgreSQL\) 12.\d/) }
    its('exit_status') { should eq 0 }
  end

  describe command("#{pg_path}11/bin/psql -V") do
    its('stdout') { should match(/psql \(PostgreSQL\) 11.\d/) }
    its('exit_status') { should eq 0 }
  end

  describe command("#{pg_path}12/bin/psql -V") do
    its('stdout') { should match(/psql \(PostgreSQL\) 12.\d/) }
    its('exit_status') { should eq 0 }
  end
end
