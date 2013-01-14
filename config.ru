# config.ru
require 'rubygems'
require 'bundler'

Bundler.require

require './lib/mithril'

#=# Initialise Logging #=#
log_path = "log/development.log"
if File.exists? log_path
  File.truncate log_path, 0
else
  File.write log_path, ''
end # if-else

logger = Logger.new log_path
logger.formatter = Proc.new do |severity, datetime, progname, message|
  message
end # anonymous proc
logger.info "~~~~~\nSinatra has taken the stage...\n"

logger.formatter = Proc.new do |severity, datetime, progname, message|
  "#{severity}: #{message}\n"
end # anonymous proc
Mithril.logger = logger

require './app/app'
run Mithril::App
