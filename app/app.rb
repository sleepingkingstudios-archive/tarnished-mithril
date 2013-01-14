# app.rb

require "sinatra/activerecord"

#=# Update Load Path #=#
$LOAD_PATH << "./lib"

require 'controllers/routing_controller'

module Mithril
  class App < Sinatra::Base
    configure :development do
      dbconfig = YAML::load(File.open('./config/database.yml'))
      ActiveRecord::Base.establish_connection( dbconfig[environment.to_s] )
      
      #=# Initialise Logging #=#
      log_path = "log/development.log"
      if File.exists? log_path
        File.truncate log_path, 0
      else
        File.write log_path, ''
      end # if-else

      logger = Logger.new log_path
      logger.formatter = Proc.new do |severity, datetime, progname, message|
        message
      end # anonymous proc
      logger.info "~~~~~\nSinatra has taken the stage...\n"

      logger.formatter = Proc.new do |severity, datetime, progname, message|
        "#{severity}: #{message}\n"
      end # anonymous proc
      Mithril.logger = logger
    end # configure development
    
    configure :test do
      dbconfig = YAML::load(File.open('./config/database.yml'))
      ActiveRecord::Base.establish_connection( dbconfig[environment.to_s] )
    end # configure test
    
    #=# Assets #=#
    get "/scripts/:path" do
      coffee :"js/#{params[:path].gsub(/.js$/,'')}"
    end # get
    
    get "/stylesheets/:path" do
      scss :"css/#{params[:path].gsub(/.css$/,'')}"
    end # get
    
    get "/" do
      if request.xhr?
        Mithril.logger.debug "params = #{request.params.inspect}, xhr? = #{request.xhr?}"
        
        controller = Mithril::Controllers::RoutingController.new
        { :text => controller.invoke_command(Hash.new, request.params["text"]) }.to_json
      else
        haml :console
      end # if-else
    end # get
  end # class
end # module
