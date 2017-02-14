# frozen_string_literal: true
pg_version = attribute('pg_version', default: nil, description: 'PostgreSQL installed version by default')

if pg_version.nil?
  # Default values per platform/version
  case os[:family]
  when 'redhat'
    case os[:release]
    when /(5|6)\.\d+/
      pg_version = '8.4'

    when /7\.\d+/
      pg_version = '9.2'
    end

  when 'fedora'
    case os[:release]
    when '25'
      pg_version = '9.5'
    end

  when 'debian'
    case os[:release]
    when /7\.\d+/
      pg_version = '9.1'

    when /8\.\d+/
      pg_version = '9.4'

    # Ubuntu versions
    when '12.04'
      pg_version = '9.1'

    when '14.04'
      pg_version = '9.3'

    when '16.04'
      pg_version = '9.5'
    end

  when 'suse'
    case os[:release]
    when '42.2'
      pg_version = '9.4'

    when '13.2'
      pg_version = '9.3'
    end
  end
end

describe command('/usr/bin/psql --help') do
  its('exit_status') { should eq 0 }
end

describe command('/usr/bin/psql -V') do
  its('stdout') { should match(/psql \(PostgreSQL\) #{pg_version}/) }
  its('exit_status') { should eq 0 }
end
