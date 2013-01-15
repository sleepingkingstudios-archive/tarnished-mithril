# config/initializers/ingots.rb

require 'mithril'
require 'sinatra'

unless :test == Sinatra::Base.environment
  Dir["modules/*/ingot.rb"].each { |file| require File.join ".", file }
end # unless
