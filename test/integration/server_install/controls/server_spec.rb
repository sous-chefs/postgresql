# frozen_string_literal: true
describe service('postgresql-9.5') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end
