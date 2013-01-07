# app.rb
module Mithril
  class App < Sinatra::Base
    get "/" do
      "Greetings, programs!"
    end # get
  end # class
end # module
