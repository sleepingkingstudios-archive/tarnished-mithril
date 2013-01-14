# lib/controllers/mixins/module_actions.rb

require 'controllers/mixins/actions_base'
require 'controllers/mixins/module_helpers'
require 'ingot'

module Mithril::Controllers::Mixins
  # Actions for closing a module.
  module ModuleActions
    extend ActionMixin
    
    mixin ActionsBase
    mixin ModuleHelpers
    
    define_action :close do |session, arguments|
      if arguments.first =~ /help/i
        return "The close command closes the current module, allowing you to" +
          " log out or to select a different interactive module."
      elsif current_module(session).nil?
        return "There is currently no module selected."
      end # if
      
      name = current_module(session).name
      session[:module_key] = nil
      "The #{name} module has been closed."
    end # action close
  end # module
end # module