# frozen_string_literal: true
describe service('postgresql') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end
