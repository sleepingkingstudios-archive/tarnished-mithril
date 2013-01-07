# config.ru
require 'rubygems'
require 'bundler'

Bundler.require

require './mithril_app'
run Mithril::App
