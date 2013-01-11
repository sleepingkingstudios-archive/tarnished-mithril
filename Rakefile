# Rakefile
require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'
require 'rdoc'
require 'rspec/core/rake_task'
require './app'

#=#==============#=#
#=# Define Tasks #=#

RSpec::Core::RakeTask.new(:spec)

task :default do
  puts "Default is the best fault to have."
end # task default

task :rdoc do
  `rdoc --main=Mithril::App --exclude=db --exclude=spec`
end # task rdoc
