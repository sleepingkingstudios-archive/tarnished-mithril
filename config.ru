# config.ru
root_path = File.dirname(__FILE__)
require File.join root_path, 'config', 'environment'
require File.join root_path, 'config', 'logger'
require File.join root_path, 'app', 'app'

run Mithril::App
