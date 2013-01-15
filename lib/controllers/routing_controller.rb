# lib/controllers/routing_controller.rb

require 'controllers/proxy_controller'
require 'controllers/session_controller'
require 'controllers/user_controller'
require 'controllers/mixins/help_actions'
require 'controllers/mixins/module_helpers'
require 'controllers/mixins/user_helpers'
require 'ingots/ingots'

module Mithril::Controllers
  class RoutingController < ProxyController
    mixin Mixins::HelpActions
    mixin Mixins::ModuleHelpers
    mixin Mixins::UserHelpers
    
    def invoke_command(session, text)
      @session = session; out = super; @session = nil; return out
    end # method invoke_command
    
    def invoke_action(session, command, arguments)
      @session = session; out = super; @session = nil; return out
    end # method invoke_action
    
    def proxy
      session = @session || {}
      
      if current_user(session).nil?
        UserController.new
      elsif (current_module = Mithril::Ingots::Ingot.find(session[:module_key])).nil?
        SessionController.new
      else
        current_module.controller.new
      end # if-else
    end # method proxy
  end # class RoutingController
end # module
