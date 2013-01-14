# lib/controllers/routing_controller.rb

require 'controllers/proxy_controller'
require 'controllers/session_controller'
require 'controllers/user_controller'
require 'controllers/mixins/help_actions'
require 'controllers/mixins/user_helpers'

module Mithril::Controllers
  class RoutingController < ProxyController
    mixin Mixins::HelpActions
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
      else
        SessionController.new
      end # if-else
    end # method proxy
  end # class RoutingController
end # module
