control 'postgresl-local-access' do
  impact 1.0
  desc '
    This test ensures postgres has local trust access to the database
  '

  describe postgres_hba_conf.where { type == 'host' } do
    its('database') { should cmp 'all' }
    its('user') { should cmp 'postgres' }
    its('auth_method') { should cmp 'md5' }
  end
end
