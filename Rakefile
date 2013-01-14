# Rakefile
require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'
require 'rdoc'
require './app/app'

#=#==============#=#
#=# Define Tasks #=#

task :default => :interactive

task :interactive do
  require 'controllers/routing_controller'
  
  session    = {}
  controller = Mithril::Controllers::RoutingController.new
  
  loop do
    print "> "
    input = gets.strip
    
    if input =~ /^quit/i
      puts "Thanks for playing!"
      break
    end # if
    
    puts controller.invoke_command(session, input)
    puts session
  end # loop
end # task interactive

task :rdoc do
  `rdoc --main=Mithril::App --exclude=db --exclude=spec`
end # task rdoc
