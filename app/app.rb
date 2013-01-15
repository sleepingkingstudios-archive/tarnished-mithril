# app.rb

require 'controllers/routing_controller'

module Mithril
  class App < Sinatra::Base
    enable :sessions
    
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
        { :text => controller.invoke_command(session, request.params["text"]) }.to_json
      else
        haml :console
      end # if-else
    end # get
  end # class
end # module
