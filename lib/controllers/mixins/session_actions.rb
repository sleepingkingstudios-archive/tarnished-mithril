# lib/controllers/mixins/session_actions.rb

require 'controllers/mixins/actions_base'
require 'controllers/mixins/user_helpers'

module Mithril::Controllers::Mixins
  module SessionActions
    extend ActionMixin
    
    mixin ActionsBase
    mixin UserHelpers
    
    define_action :logout do |session, arguments|
      if arguments.first =~ /help/i
        return "The logout action ends the current user session."
      elsif current_user(session).nil?
        return "You are not currently logged in."
      end # if
      
      session[:user_id] = nil
      "You have successfully logged out."
    end # action logout
  end # module SessionActions
end # module
