# lib/controllers/routing_controller.rb

require 'controllers/proxy_controller'
require 'controllers/user_controller'
require 'controllers/mixins/help_actions'

module Mithril::Controllers
  class RoutingController < ProxyController
    mixin Mixins::HelpActions
    
    def invoke_command(session, text)
      @session = session; out = super; @session = nil; return out
    end # method invoke_command
    
    def invoke_action(session, command, arguments)
      @session = session; out = super; @session = nil; return out
    end # method invoke_action
    
    def proxy
      UserController.new
    end # method proxy
  end # class RoutingController
end # module
