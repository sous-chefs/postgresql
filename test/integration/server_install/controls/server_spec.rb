# frozen_string_literal: true
pg_ver = input('pg_ver')

if os[:family] == 'redhat' || os[:family] == 'fedora'
  describe service("postgresql-#{pg_ver}") do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end
else
  describe service('postgresql') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end
end
