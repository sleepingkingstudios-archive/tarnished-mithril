# config/initializers/ingots.rb

require 'mithril'
require 'sinatra'

Dir["modules/*/ingot.rb"].each { |file| require File.join ".", file }
