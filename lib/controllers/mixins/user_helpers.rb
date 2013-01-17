# lib/controllers/mixins/user_helpers.rb

require 'controllers/mixins/mixins'
require 'models/user'

module Mithril::Controllers::Mixins
  module UserHelpers
    extend ActionMixin
    
    def current_user
      request ? request.user : nil
    end # method current_user
  end # module UserHelpers
end # module
