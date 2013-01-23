# lib/controllers/routing_controller.rb

require 'controllers/callback_controller'
require 'controllers/proxy_controller'
require 'controllers/session_controller'
require 'controllers/user_controller'
require 'controllers/mixins/callback_helpers'
require 'controllers/mixins/help_actions'
require 'controllers/mixins/module_helpers'
require 'controllers/mixins/user_helpers'
require 'ingots/ingots'

module Mithril::Controllers
  class RoutingController < ProxyController
    mixin Mixins::CallbackHelpers
    mixin Mixins::HelpActions
    mixin Mixins::ModuleHelpers
    mixin Mixins::UserHelpers
    
    def proxy
      session = request.session
      
      if current_user.nil?
        UserController.new request
      elsif has_callbacks?(session)
        CallbackController.new request
      elsif current_module.nil?
        SessionController.new request
      else
        current_module.controller.new request
      end # if-else
    end # method proxy
  end # class RoutingController
end # module
