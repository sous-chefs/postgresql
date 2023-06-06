
control 'test1 database should exist' do
  impact 1.0
  desc 'The test1 database should exist'

  postgres_access = postgres_session('postgres', '12345', '127.0.0.1')

  describe postgres_access.query('SELECT * FROM pg_database;') do
    its('output') { should include 'sous_chef' }
    its('output') { should include 'test1' }
    its('output') { should_not include 'test2' }
  end
end
