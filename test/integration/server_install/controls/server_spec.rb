# frozen_string_literal: true

if os[:family] == 'redhat' || os[:family] == 'fedora'
  describe service('postgresql-9.6') do
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
