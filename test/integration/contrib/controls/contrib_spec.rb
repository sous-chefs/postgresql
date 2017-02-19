# frozen_string_literal: true
include_controls 'server'

sql = postgres_session('postgres', 'iloverandompasswordsbutthiswilldo')

%w(plpgsql xml2).each do |pg_ext|
  describe sql.query("SELECT 'installed' FROM pg_extension WHERE extname = '#{pg_ext}';", ['template1']) do
    its(:lines) { should eq ['installed'] }
  end
end
