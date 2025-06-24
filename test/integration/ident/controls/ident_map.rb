control 'postgresql-ident-map' do
  impact 1.0
  desc 'This test ensures postgres configures ident access correctly'

  describe command("sudo -u shef bash -c \"psql -U sous_chef -d postgres -c 'SELECT 1;'\"") do
    its('exit_status') { should eq 0 }
  end
end

control 'postgresql-ident-multi-map' do
  impact 1.0
  desc 'This test ensures postgres configures ident access with multiple mappings correctly'

  describe command("sudo -u shef bash -c \"psql -U sous_chef -d test1 -c 'SELECT 1;'\"") do
    its('exit_status') { should eq 0 }
  end

  describe command("sudo -u shef2 bash -c \"psql -U sous_chef -d test1 -c 'SELECT 1;'\"") do
    its('exit_status') { should eq 0 }
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

control 'postgresql-ident-long-map-name' do
  impact 1.0
  desc 'This test ensures postgres configures ident access with long map names correctly'

  describe postgres_ident_conf.where { map_name == 'this_is_a_very_long_map_name_that_should_be_handled_correctly_by_the_postgresql_ident_resource' } do
    its('system_username') { should cmp 'shef' }
    its('pg_username') { should cmp 'sous_chef' }
  end
end
