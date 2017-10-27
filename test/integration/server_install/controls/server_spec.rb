# frozen_string_literal: true

svc_name = os[:family] == 'rhel' ? 'postgresql-96' : 'postgresql'

describe service(svc_name) do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end
