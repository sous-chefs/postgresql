control 'postgresl-ident-map' do
  impact 1.0
  desc '
    This test ensures postgres configures ident access correctly
  '

  describe postgres_ident_conf.where { pg_username == 'sous_chef' } do
    its('system_username') { should eq ['shef'] }
  end

  describe command("sudo -u shef bash -c \"psql -U sous_chef -d postgres -c 'SELECT 1;'\"") do
    its('exit_status') { should eq 0 }
  end
end
