# frozen_string_literal: true
pg_ver = input('pg_ver')

if os[:family] == 'redhat'
  describe service("postgresql-#{pg_ver}") do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end
  %W(pgdg#{pg_ver} pgdg-common).each do |r|
    describe yum.repo(r) do
      it { should exist }
      it { should be_enabled }
    end
  end
  %W(pgdg#{pg_ver}-source pgdg#{pg_ver}-updates-testing pgdg#{pg_ver}-source-updates-testing).each do |r|
    describe yum.repo(r) do
      it { should exist }
      it { should_not be_enabled }
    end
  end
else
  describe service('postgresql') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end
end
