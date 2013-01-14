# lib/controllers/session_controller.rb

require 'controllers/abstract_controller'
require 'controllers/mixins/session_actions'

module Mithril::Controllers
  class SessionController < AbstractController
    mixin Mixins::HelpActions
    mixin Mixins::SessionActions
  end # class
end # module
