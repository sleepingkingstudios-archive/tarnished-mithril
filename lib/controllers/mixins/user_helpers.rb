# lib/controllers/mixins/user_helpers.rb

require 'controllers/mixins/mixins'
require 'models/user'

module Mithril::Controllers::Mixins
  module UserHelpers
    extend ActionMixin
    
    def current_user(session)
      begin
        Mithril::Models::User.find(session[:user_id])
      rescue ActiveRecord::RecordNotFound
        nil
      end # begin-rescue
    end # method current_user
  end # module UserHelpers
end # module