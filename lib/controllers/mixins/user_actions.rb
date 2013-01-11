# lib/controllers/mixins/user_actions.rb

require 'controllers/mixins/actions_base'

module Mithril::Controllers::Mixins
  module UserActions
    extend ActionMixin
  
    mixin ActionsBase
    
    def allow_registration?
      false
    end # method allow_registration
    
    define_action :register do |session, arguments|
      unless allow_registration?
        return "Direct registration is currently closed. Please contact the site" +
          " administrator for guest access information."
      end # unless
      
      if arguments.first =~ /help/i
        return "The register command allows you to register as a new user." +
          " The username must be unique, and the password and password" +
          " confirmation must match.\n\nFormat: register USERNAME PASSWORD" +
          " PASSWORD_CONFIRMATION"
      elsif 3 > arguments.count
        return "Registration requires a username, password, and password" +
          " confirmation. For more information, enter \"register help\"."
      end # if
      
      username = arguments[0]
      
      # Validate uniqueness of user here...
      
      password = arguments[1]
      confirm  = arguments[2]
      
      unless password == confirm
        return "Password and confirmation do not match. Please try again."
      end # if
      
      # Create User model here...
      
      "Successfully created user \"#{username}\"."
    end # define action
  end # module UserActions
end # module
