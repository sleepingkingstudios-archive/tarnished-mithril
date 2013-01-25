# Rakefile
require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'
require 'rdoc'

#=#==============#=#
#=# Define Tasks #=#

task :environment do
  root_path = File.dirname(__FILE__)
  require File.join root_path, 'config', 'environment'
  require File.join root_path, 'config', 'logger'
  require File.join root_path, 'app', 'app'
end # task environment

task :default => :interactive

task :interactive => :environment do
  require 'controllers/routing_controller'
  require 'request'
  
  Mithril.logger << "\n~~~~~\nStarting interactive session...\n\n"
  
  session    = {}
  
  loop do
    print "> "
    input = gets.strip
    
    if input =~ /^quit/i
      puts "Thanks for playing!"
      break
    end # if
    
    request    = Mithril::Request.new
    request.session = session
    controller = Mithril::Controllers::RoutingController.new request
    
    puts controller.invoke_command(input)
    puts controller.proxy.class.name
    puts session
  end # loop
end # task interactive

task :rdoc do
  `rdoc --main=Mithril::App --exclude=db --exclude=spec`
end # task rdoc
