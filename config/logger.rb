# config/logger.rb

require 'logger'
require 'sinatra'
require 'mithril'

log_path = {
  :development => "log/development.log",
  :test => "log/spec.log",
}[Sinatra::Base.environment]

unless log_path.nil?
  File.exists?(log_path) ?
    File.truncate(log_path, 0) :
    File.write(log_path, '')

  logger = Logger.new log_path
  logger.formatter = Proc.new do |severity, datetime, progname, message|
    "#{severity}: #{message}\n"
  end # formatter
  Mithril.logger = logger
end # unless

