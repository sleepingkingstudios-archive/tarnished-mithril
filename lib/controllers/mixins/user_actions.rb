# lib/controllers/mixins/user_actions.rb

require 'controllers/mixins/actions_base'
require 'models/user'

module Mithril::Controllers::Mixins
  module UserActions
    extend ActionMixin
  
    mixin ActionsBase
    
    def allow_registration?
      false
    end # method allow_registration
    
    define_action :login do |session, arguments|
      if arguments.first =~ /help/i
        return "The login command allows you to start or resume an" +
        " interactive session. You must enter your username and password." +
        "\n\nFormat: login USERNAME PASSWORD"
      elsif session.has_key?(:user_id)
        return "You are already logged in as another user. Please log out" +
          " so you can log in as a new user."
      elsif 2 > arguments.count
        return "Logging in requires a username and password. For more information," +
          " enter \"login help\"."
      end # if-elsif
      
      username = arguments[0]
      password = arguments[1]
      
      user = Mithril::Models::User.find_by_username(username)
      if user && user.authenticate(password)
        session[:user_id] = user.id
        "You are now logged in as \"#{username}\"."
      else
        "Unable to authenticate user."
      end # if-else
    end # action login
    
    define_action :register do |session, arguments|
      unless allow_registration?
        return "Online registration is currently closed. Please contact the site" +
          " administrator for guest access information."
      end # unless
      
      if arguments.first =~ /help/i
        return "The register command allows you to register as a new user." +
          " The username must be unique, and the password and password" +
          " confirmation must match.\n\nFormat: register USERNAME PASSWORD" +
          " PASSWORD_CONFIRMATION"
      elsif session.has_key?(:user_id)
        return "You are already logged in as another user. Please log out" +
          " so you can register a new user."
      elsif 3 > arguments.count
        return "Registration requires a username, password, and password" +
          " confirmation. For more information, enter \"register help\"."
      end # if
      
      username = arguments[0]
      
      if Mithril::Models::User.exists? :username => username
        return "I'm sorry, there is already a user named \"#{username}\"." +
          " Please choose another name and try again."
      end # if
      
      password = arguments[1]
      confirm  = arguments[2]
      
      unless password == confirm
        return "Password and confirmation do not match. Please try again."
      end # if
      
      user = Mithril::Models::User.new :username => username,
        :password => password, :password_confirmation => password
      
      if user.save
        session[:user_id] = user.id
        "Successfully created user. You are now logged in as \"#{username}\"."
      else
        "Unable to create user because of the following errors: #{user.errors.inspect}"
      end # if-else
    end # action register
  end # module UserActions
end # module
