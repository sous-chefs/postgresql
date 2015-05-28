COOKBOOK_RESOLVERS = {
  'batali' => ['Batali', 'batali/chefspec'],
  'berkshelf' => ['Berksfile', 'chefspec/berkshelf'],
  'librarian' => ['Cheffile', 'chefspec/librarian']
}

require 'chefspec'

if ENV['COOKBOOK_RESOLVER']
  require COOKBOOK_RESOLVERS[ENV['COOKBOOK_RESOLVER']]
else
  resolver_lib = COOKBOOK_RESOLVERS.values.detect do |r_file, _r_lib|
    File.exist?(File.join(File.dirname(__FILE__), '..', r_file))
  end
  fail 'Failed to locate valid cookbook resolver files!' unless resolver_lib
  puts "Resolving cookbooks from #{resolver_lib.first}"
  require resolver_lib.last
end

at_exit { ChefSpec::Coverage.report! }
