# frozen_string_literal: true
file '/tmp/pg_gem_test.rb' do
  content "#!/opt/chef/embedded/bin/ruby\nrequire 'pg'"
  mode '755'
end
