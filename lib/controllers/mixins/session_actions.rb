# lib/controllers/mixins/session_actions.rb

require 'controllers/mixins/actions_base'
require 'controllers/mixins/user_helpers'
require 'ingots/ingots'

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
      
      session[:module_key] = nil
      session[:user_id] = nil
      "You have successfully logged out."
    end # action logout
    
    define_action :module do |session, arguments|
      module_list = Mithril::Ingots::Ingot.all
      
      if arguments.first =~ /help/i
        return "The module command allows you to select an interactive" +
          " module. For a list of all available modules, enter \"module" +
          " list\". To select a module, enter \"module\" followed by the" +
          " module name.\n\nFormat: module MODULE_NAME"
      elsif arguments.first =~ /list/i
        if module_list.nil? || 0 == module_list.count
          return "There are currently no modules available."
        else
          module_names = module_list.map { |key, value| value.name }
          
          return "The following modules are available: #{module_names.join(", ")}"
        end # if-else
      elsif 1 > arguments.count
        return "You must enter a module name. For more information, enter" +
          " \"module help\"."
      end # if
      
      current_module = Mithril::Ingots::Ingot.find session[:module_key]
      
      unless current_module.nil?
        return "There is already a module selected. To open a new module," +
          " please close the current module."
      end # unless
      
      module_key = arguments.join '_'
      current_module = Mithril::Ingots::Ingot.find module_key
      
      unless current_module.nil?
        session[:module_key] = current_module.key
        "You have selected the #{arguments.join ' '} module."
      else
        "Unable to load module \"#{arguments.join ' '}\""
      end # unless-else
    end # action module
  end # module SessionActions
end # module
