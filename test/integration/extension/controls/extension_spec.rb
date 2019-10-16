control 'postgresql-extension' do
  impact 1.0
  desc 'Check if the "plpgsql" extension was installed successfully'

  postgres_access = postgres_session('postgres', '12345', '127.0.0.1')

  describe postgres_access.query('\dx;', ['test_1']) do
    its('output') { should include 'plpgsql' }
  end
end

control 'postgresql-extension-hyphenated' do
  impact 1.0
  desc 'Check if the "uuid-ossp" extension was installed successfully'

  postgres_access = postgres_session('postgres', '12345', '127.0.0.1')

  describe postgres_access.query('\dx;', ['test_1']) do
    its('output') { should include 'ossp' }
  end
end
