# frozen_string_literal: true

describe gem('pg', '/opt/chef/embedded/bin/gem') do
  it { should be_installed }
end
