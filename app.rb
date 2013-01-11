# app.rb

require "sinatra/activerecord"

#=# Update Load Path #=#
$LOAD_PATH << "./lib"

require 'mithril'
require 'models/user'

#=# Establish DB Connection #=#
dbconfig = YAML::load(File.open('./config/database.yml'))
ActiveRecord::Base.establish_connection( dbconfig["test"] )

module Mithril
  class App < Sinatra::Base
    get "/" do
      "Greetings, programs! Users = #{Mithril::Models::User.all}"
    end # get
  end # class
end # module
