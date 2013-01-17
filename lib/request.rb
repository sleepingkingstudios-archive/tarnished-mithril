# lib/request.rb

require 'mithril'
require 'models/user'

module Mithril
  class Request
    def user
      return @user unless @user.nil?

      return nil if session.nil? || session[:user_id].nil?
      return @user = Mithril::Models::User.find(session[:user_id])
    rescue ActiveRecord::ConnectionNotEstablished
      return nil
    rescue ActiveRecord::RecordNotFound
      return nil
    end # method user
    
    attr_accessor :session, :text
  end # class
end # module
