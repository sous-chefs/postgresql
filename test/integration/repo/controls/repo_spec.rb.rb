# frozen_string_literal: true
pg_ver = input('pg_ver')

case os[:family]

when 'redhat', 'fedora'

  describe yum.repo("pgdg#{pg_ver}") do
    it { should exist }
    it { should be_enabled }
  end

  describe yum.repo("pgdg#{pg_ver}-source") do
    it { should exist }
    it { should_not be_enabled }
  end

  describe yum.repo("pgdg#{pg_ver}-source-updates-testing") do
    it { should exist }
    it { should_not be_enabled }
  end

  describe yum.repo("pgdg#{pg_ver}-updates-testing") do
    it { should exist }
    it { should_not be_enabled }
  end

when 'debian'

  describe apt('https://download.postgresql.org/pub/repos/apt/') do
    it { should exist }
    it { should be_enabled }
  end
end
