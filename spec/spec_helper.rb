# spec/spec_helper.rb

require 'mithril'
require 'logger'

#=#====================#=#
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

#=#=================#=#
#=# Configure RSpec #=#

RSpec.configure do |config|
  config.order = "random"
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
