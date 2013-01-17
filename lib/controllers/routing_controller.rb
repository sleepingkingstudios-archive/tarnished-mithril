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
    
    def invoke_command(session, text)
      @session = session; out = super; @session = nil; return out
    end # method invoke_command
    
    def invoke_action(session, command, arguments, allow_private = false)
      @session = session
      
      user_id    = session[:user_id]
      module_key = session[:module_key]
      
      out = super(session, command, arguments, allow_private)
      
      session[:user_id] = user_id unless
        user_id.nil? || session[:user_id].nil? || user_id == session[:user_id]
      session[:module_key] = module_key unless
        module_key.nil? || session[:module_key].nil? || module_key == session[:module_key]
      
      @session = nil
      
      return out
    end # method invoke_action
    
    def proxy
      session = @session || {}
      
      if current_user(session).nil?
        UserController.new
      elsif has_callbacks?(session)
        CallbackController.new
      elsif (current_module = current_module(session)).nil?
        SessionController.new
      else
        current_module.controller.new
      end # if-else
    end # method proxy
  end # class RoutingController
end # module
