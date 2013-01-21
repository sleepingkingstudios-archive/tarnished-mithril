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
    
    def invoke_action(command, arguments, allow_private = false)
      session    = request.session
      user_id    = session[:user_id]
      module_key = session[:module_key]
      
      out = super(command, arguments, allow_private)
      
      session[:user_id] = user_id unless
        user_id.nil? || session[:user_id].nil? || user_id == session[:user_id]
      session[:module_key] = module_key unless
        module_key.nil? || session[:module_key].nil? || module_key == session[:module_key]
      
      return out
    end # method invoke_action
    
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
