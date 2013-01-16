# lib/controllers/mixins/module_helpers.rb

require 'controllers/mixins/mixins'
require 'ingots/ingots'

module Mithril::Controllers::Mixins
  module ModuleHelpers
    extend ActionMixin
    
    def current_module(session)
      session ||= {}
      Mithril::Ingots::Ingot.find(session[:module_key])
    end # method current_user
  end # module UserHelpers
end # module