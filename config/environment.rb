# config/environment.rb

require 'rubygems'
require 'bundler'

Bundler.require

root_path = File.dirname(__FILE__).gsub(/config$/, '')
core_path = File.join root_path, 'lib'

$LOAD_PATH.unshift(core_path) unless $LOAD_PATH.include?(core_path)

#=# Establish Database Connection #=#
dbconfig = YAML::load File.open File.join root_path, 'config', 'database.yml'
ActiveRecord::Base.establish_connection( dbconfig[Sinatra::Base.environment.to_s] )

#=# Load Initializers #=#
Dir["#{root_path}/config/initializers/**/*.rb"].each{ |s| load s }
