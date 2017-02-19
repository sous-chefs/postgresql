# frozen_string_literal: true
include_controls 'server'

sql = postgres_session('postgres', 'iloverandompasswordsbutthiswilldo')

begin
  pg_version = sql.query('SELECT version();').lines[0].split(' ')[1]
  extension_support = Gem::Version.new(pg_version) >= Gem::Version.new('9.1')
rescue
  extension_support = true
end

control 'check_installed_extensions' do
  only_if do
    extension_support
  end

  %w(plpgsql xml2).each do |pg_ext|
    describe sql.query("SELECT 'installed' FROM pg_extension WHERE extname = '#{pg_ext}';", ['template1']) do
      its(:lines) { should eq ['installed'] }
    end
  end
end
