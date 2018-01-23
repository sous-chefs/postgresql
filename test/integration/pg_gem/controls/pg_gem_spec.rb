# frozen_string_literal: true

describe gem('pg', '/usr/local/rbenv/shims/gem') do
  it { should be_installed }
end
