# lib/controllers/spooky_controller.rb

require 'controllers/abstract_controller'
require 'controllers/mixins/callback_helpers'
require 'controllers/mixins/help_actions'

module Mithril::Controllers
  class CallbackController < AbstractController
    mixin Mixins::CallbackHelpers
    mixin Mixins::HelpActions
    
    def initialize(request)
      Mithril.logger.debug "CallbackController.initialize()" if request.nil?
      
      super
    end # method initialize
    
    def actions(allow_private = false)
      actions = super
      actions = actions.dup.update(@callbacks) unless @callbacks.nil? || @callbacks.empty?
      
      actions
    end # method actions
    
    def invoke_action(command, arguments, allow_private = false)
      Mithril.logger.debug "CallbackController.invoke_action()" if request.nil?
      
      unless (callbacks = self.get_callbacks(request.session)).nil?
        @callbacks = self.deserialize_callbacks callbacks
      end # unless
      
      return super if @callbacks.nil?
      
      unless (callback = @callbacks[command]).nil?
        controller = callback[:controller]
        action     = callback[:action]
        
        self.clear_callbacks(request.session)
        
        return controller.new(request).invoke_action(action, arguments, true)
      end # if
      
      super
    end # method invoke_action
    
    def invoke_command(text)
      unless (callbacks = self.get_callbacks(request.session)).nil?
        @callbacks = self.deserialize_callbacks callbacks
      end # unless
      
      super
    end # method invoke_command
  end # class CallbackController
end # module
