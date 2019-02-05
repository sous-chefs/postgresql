control 'postgresql-extension' do
  impact 1.0
  desc 'Check if the "adminpack" extension was installed successfully'

  postgres_access = postgres_session('postgres', '12345', '127.0.0.1')

  describe postgres_access.query('\dx;', ['test_1']) do
    its('output') { should include 'adminpack' }
  end
end
