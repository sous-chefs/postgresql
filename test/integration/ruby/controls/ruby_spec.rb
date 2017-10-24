# frozen_string_literal: true

describe command('/tmp/pg_gem_test.rb') do
  its('exit_status') { should eq 0 }
end
