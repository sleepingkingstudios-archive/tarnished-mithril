# app.rb

require "sinatra/activerecord"

#=# Update Load Path #=#
$LOAD_PATH << "./lib"

require 'mithril'
require 'controllers/routing_controller'
require 'models/user'

module Mithril
  class App < Sinatra::Base
    #=# Establish DB Connection #=#
    dbconfig = YAML::load(File.open('./config/database.yml'))
    ActiveRecord::Base.establish_connection( dbconfig[environment.to_s] )
    
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
