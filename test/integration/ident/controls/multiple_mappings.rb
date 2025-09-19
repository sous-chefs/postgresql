control 'postgresql-ident-map' do
  impact 1.0
  desc 'This test ensures postgres configures ident access correctly'

  describe command("sudo -u shef bash -c \"psql -U sous_chef -d postgres -c 'SELECT 1;'\"") do
    its('exit_status') { should eq 0 }
  end
end

control 'postgresql-ident-multiple-mappings' do
  impact 1.0
  desc 'This test ensures multiple mappings per map name work correctly (issue #787)'

  # Use a command to find and check the pg_ident.conf file
  describe command("find /etc /var -name 'pg_ident.conf' 2>/dev/null | head -1 | xargs cat") do
    its('stdout') { should match(/^someuser_postgres\s+someuser\s+postgres/) }
    its('stdout') { should match(/^someuser_postgres\s+postgres\s+postgres/) }
  end
end

control 'shef and postgres roles should exist' do
  impact 1.0
  desc 'The shef & postgres database user role should exist'

  postgres_access = postgres_session('postgres', '12345', '127.0.0.1')

  describe postgres_access.query('SELECT rolname FROM pg_roles;') do
    its('output') { should include 'postgres' }
    its('output') { should include 'sous_chef' }
  end
end
