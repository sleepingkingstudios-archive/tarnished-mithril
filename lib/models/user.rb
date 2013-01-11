# lib/models/user.rb

require 'models/models'

module Mithril::Models
  # === Fields
  # * id (integer): primary key
  # * username (string)
  # * password_digest (string): for has_secure_password
  # * created_at (datetime)
  # * updated_at (datetime)
  class User < ActiveRecord::Base
    has_secure_password

    attr_accessible :username, :password, :password_confirmation
    
    #=# Validation #=#
    validates :username,              :presence => true, :uniqueness => true
    validates :password,              :presence => { :on => :create }
    validates :password_confirmation, :presence => { :on => :create }
  end # class User
end # module
