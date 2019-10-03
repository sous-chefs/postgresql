# frozen_string_literal: true

case os[:family]

when 'redhat'

  describe yum.repo('pgdg9.5') do
    it { should exist }
    it { should be_enabled }
  end

  describe yum.repo('pgdg9.5-source') do
    it { should exist }
    it { should_not be_enabled }
  end

  describe yum.repo('pgdg9.5-source-updates-testing') do
    it { should exist }
    it { should_not be_enabled }
  end

  describe yum.repo('pgdg9.5-updates-testing') do
    it { should exist }
    it { should_not be_enabled }
  end

when 'debian'

  describe apt('https://download.postgresql.org/pub/repos/apt/') do
    it { should exist }
    it { should be_enabled }
  end
end
