control 'postgresl-local-access' do
  impact 1.0
  desc '
    This test ensures postgres has localhost access to the database
  '

  describe postgres_hba_conf.where { type == 'host' && user == 'postgres' } do
    its('database') { should cmp 'all' }
    its('user') { should cmp 'postgres' }
    its('auth_method') { should cmp 'md5' }
    its('address') { should cmp '127.0.0.1/32' }
  end
end

control 'postgresl-sous-chef-access' do
  impact 1.0
  desc '
    This test ensures sous_chefs have local trust access to the database
  '

  describe postgres_hba_conf.where { user == 'sous_chef' } do
    its('database') { should cmp 'all' }
    its('type') { should cmp 'local' }
    its('auth_method') { should cmp 'peer' }
  end
end
