control 'postgresql-initdb-locale' do
  impact 1.0
  desc 'This test ensures the locales are correcly set'

  postgres_access = postgres_session('postgres', '12345', '127.0.0.1')

  describe postgres_access.query('SHOW lc_collate;') do
    its('output') { should include 'en_GB.utf8' }
  end

  describe postgres_access.query('SHOW lc_messages;') do
    its('output') { should include 'en_GB.utf8' }
  end
end
