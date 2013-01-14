# lib/controllers/mixins/session_actions.rb

require 'controllers/mixins/actions_base'
require 'models/user'

module Mithril::Controllers::Mixins
  module SessionActions
    extend ActionMixin
    
    mixin ActionsBase
    
    def current_user(session)
      begin
        Mithril::Models::User.find(session[:user_id])
      rescue ActiveRecord::RecordNotFound
        nil
      end # begin-rescue
    end # method current_user
    
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
