#!/usr/bin/env rake

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.pattern = [ 'test/unit/**{,/*/**}/*_spec.rb' ]
  end
rescue LoadError
end

begin
  require 'kitchen/rake_tasks'
  Kitchen::RakeTasks.new
rescue LoadError
  puts '>>>>> Kitchen gem not loaded, omitting tasks' unless ENV['CI']
end

begin
  require 'emeril/rake'
rescue LoadError
  puts ">>>>> Emeril gem not loaded, omitting tasks" unless ENV['CI']
end
