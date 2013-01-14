# spec/spec_helper.rb

require 'active_record'
require 'database_cleaner'
require 'logger'
require 'yaml'

require 'mithril'

module Mithril
  module Mock; end
end # module

#=# Initialise Logging #=#
log_path = "log/spec.log"
if File.exists? log_path
  File.truncate log_path, 0
else
  File.write log_path, ''
end # if-else

logger = Logger.new "log/spec.log"
logger.formatter = Proc.new do |severity, datetime, progname, message|
  message
end # anonymous proc
logger.info "~~~~~\nRunning specs...\n"

logger.formatter = Proc.new do |severity, datetime, progname, message|
  "#{severity}: #{message}\n"
end # anonymous proc
Mithril.logger = logger

ENV['RACK_ENV'] = "test"
require './app/app'

# #=# Establish DB Connection #=#
# unless ActiveRecord::Base.connected?
#   dbconfig = YAML::load(File.open('./config/database.yml'))
#   ActiveRecord::Base.establish_connection( dbconfig["test"] )
# end # unless

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
