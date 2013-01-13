# app.rb

require "sinatra/activerecord"

#=# Update Load Path #=#
$LOAD_PATH << "./lib"

require 'mithril'
require 'models/user'

module Mithril
  class App < Sinatra::Base
    #=# Establish DB Connection #=#
    dbconfig = YAML::load(File.open('./config/database.yml'))
    ActiveRecord::Base.establish_connection( dbconfig[environment.to_s] )
    
    get "/" do
      "Greetings, programs! Users = #{Mithril::Models::User.all}"
    end # get
  end # class
end # module
