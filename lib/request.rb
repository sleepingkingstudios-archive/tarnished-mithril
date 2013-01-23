# lib/request.rb

require 'mithril'
require 'errors/security_error'
require 'models/user'

module Mithril
  class Request
    def user
      unless @user.nil?
        return @user if session.nil? || session[:user_id].nil? || session[:user_id] == @user.id
        
        session[:user_id] = @user.id
        raise Mithril::Errors::SecurityError.new "attempted to change" +
          " current user mid-request"
      end # unless
      
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
