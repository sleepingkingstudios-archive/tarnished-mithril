# spec/spec_helper.rb

ENV['RACK_ENV'] = "test"
require_relative '../config/environment'
require_relative '../config/logger'

Mithril.logger << "\n~~~~~\nRunning specs...\n\n"

require 'database_cleaner'

module Mithril
  module Mock; end
end # module

#=#=================#=#
#=# Configure RSpec #=#

RSpec.configure do |config|
  config.order = "random"
  
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end # before suite

  config.before(:each) do
    DatabaseCleaner.start
  end # before each

  config.after(:each) do
    DatabaseCleaner.clean
  end # after each
end # configure

# Require custom matchers
Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each { |f| require f }

# Monkey patch RSpec::ExampleGroup for formatted output
class RSpec::Core::ExampleGroup
  class << self
    def ancestor_examples
      self.ancestors.select do |ancestor|
        self != ancestor && ancestor < RSpec::Core::ExampleGroup
      end # select
    end # class method ancestors
    
    def context(*args, &block)
      return describe(*args, &block) if args.empty?
      
      str = args.shift
      str = "(#{str})" unless str =~ /^\(/
      
      describe("\n#{"  "*(ancestor_examples.count+1)}#{str}", *args, &block)
    end # method context
  end # class << self
end # class ExampleGroup
