require 'rspec/expectations'
require 'chefspec'
require 'chefspec/berkshelf'

# Require all our libraries
Dir['libraries/*_helper.rb'].each { |f| require File.expand_path(f) }

at_exit { ChefSpec::Coverage.report! }
