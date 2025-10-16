control 'postgresql-initdb-locale' do
  impact 1.0
  desc 'This test ensures the locales are correcly set'

  postgres_access = postgres_session('postgres', '12345', '127.0.0.1')

  describe postgres_access.query('SHOW LC_MONETARY;') do
    its('output') { should include (os.release.to_i < 8 ? 'en_US.utf8' : 'C.UTF-8').to_s }
  end

  describe postgres_access.query('SHOW LC_MESSAGES;') do
    its('output') { should include (os.release.to_i < 8 ? 'en_US.utf8' : 'C.UTF-8').to_s }
  end

  describe postgres_access.query('SHOW LC_NUMERIC;') do
    its('output') { should include (os.release.to_i < 8 ? 'en_US.utf8' : 'C.UTF-8').to_s }
  end

  describe postgres_access.query('SHOW LC_TIME;') do
    its('output') { should include (os.release.to_i < 8 ? 'en_US.utf8' : 'C.UTF-8').to_s }
  end
end
