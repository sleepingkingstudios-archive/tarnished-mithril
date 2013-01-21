# lib/controllers/spooky_controller.rb

require 'controllers/abstract_controller'
require 'controllers/mixins/callback_helpers'
require 'controllers/mixins/help_actions'

module Mithril::Controllers
  class CallbackController < AbstractController
    # mixin Mixins::CallbackHelpers
    # mixin Mixins::HelpActions
    # 
    # 
    # def actions(allow_private = false)
    #   actions = super
    #   actions = actions.dup.update(@callbacks) unless @callbacks.nil? || @callbacks.empty?
    #   
    #   actions
    # end # method actions
    # 
    # def invoke_action(command, arguments, allow_private = false)
    #   # session = request.session
    #   # if @callbacks || !(callbacks = self.get_callbacks(session)).nil?
    #   #   callbacks = @callbacks || self.deserialize_callbacks(callbacks)
    #   #   
    #   #   unless (callback = callbacks[command]).nil?
    #   #     controller = callback[:controller]
    #   #     action     = callback[:action]
    #   #     
    #   #     self.clear_callbacks(session)
    #   #     
    #   #     return controller.new.invoke_action(session, action, arguments, true)
    #   #   end # if
    #   # end # unless
    #   
    #   super
    # end # method invoke_action
    # 
    # def invoke_command(text)
    #   # unless (callbacks = self.get_callbacks(session)).nil?
    #   #   @callbacks = self.deserialize_callbacks callbacks
    #   # end # unless
    #   
    #   out = super
    #   
    #   # @callbacks = nil
    #   
    #   out
    # end # method invoke_command
  end # class CallbackController
end # module
