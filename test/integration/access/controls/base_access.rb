control 'postgresql-local-access' do
  impact 1.0
  desc 'This test ensures postgres has localhost access to the database'

  describe postgres_hba_conf.where { type == 'host' && user == 'postgres' } do
    its('database') { should cmp 'all' }
    its('user') { should cmp 'postgres' }
    its('auth_method') { should cmp 'md5' }
    its('address') { should cmp '127.0.0.1/32' }
  end

  postgres_access = postgres_session('postgres', '12345', '127.0.0.1')

  describe postgres_access.query('SELECT 1;') do
    its('output') { should eq '1' }
  end
end

control 'postgresql-sous-chef-access' do
  impact 1.0
  desc 'This test ensures sous_chefs have local trust access to the database'

  describe postgres_hba_conf.where { user == 'sous_chef' } do
    its('database') { should cmp 'all' }
    its('type') { should cmp 'host' }
    its('auth_method') { should cmp 'md5' }
    its('address') { should cmp '127.0.0.1/32' }
  end

  postgres_access = postgres_session('sous_chef', '67890')

  describe postgres_access.query('SELECT 1;', ['postgres']) do
    its('output') { should eq '1' }
  end
end

control 'sous_chef role should exist' do
  impact 1.0
  desc 'The sous_chef database user role should exist'

  postgres_access = postgres_session('postgres', '12345', '127.0.0.1')

  describe postgres_access.query('SELECT rolname FROM pg_roles;') do
    its('output') { should cmp /sous_chef/ }
  end
end

control 'sous_chef has statement_timeout set to 8mins' do
  impact 1.0
  desc 'Ensures attributes are applied'

  postgres_access = postgres_session('sous_chef', '67890')

  describe postgres_access.query('SHOW statement_timeout;', ['postgres']) do
    its('output') { should cmp /8min/ }
  end
end

control 'name-with-dash role should exist' do
  impact 1.0
  desc 'The name-with-dash database user role should exist'

  postgres_access = postgres_session('postgres', '12345', '127.0.0.1')

  describe postgres_access.query('SELECT rolname FROM pg_roles;') do
    its('output') { should cmp /name-with-dash/ }
  end
end
