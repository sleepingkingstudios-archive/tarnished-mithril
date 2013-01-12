# lib/controllers/user_controller.rb

require 'controllers/abstract_controller'
require 'controllers/mixins/help_actions'
require 'controllers/mixins/user_actions'

module Mithril::Controllers
  class UserController < AbstractController
    mixin Mixins::HelpActions
    mixin Mixins::UserActions
  end # class
end # module
