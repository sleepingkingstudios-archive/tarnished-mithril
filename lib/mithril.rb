# lib/mithril.rb

require 'logger'

module Mithril
  def self.logger
    return @logger ||= Logger.new(STDOUT)
  end # class accessor logger
  
  def self.logger=(logger)
    @logger = logger
  end # class mutator logger=
end # module Mithril
