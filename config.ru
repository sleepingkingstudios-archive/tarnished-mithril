# config.ru
require 'rubygems'
require 'bundler'

Bundler.require

require './app/app'
run Mithril::App
