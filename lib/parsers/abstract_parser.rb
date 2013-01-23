# lib/parsers/abstract_parser.rb

require 'parsers/parsers'

module Mithril::Parsers
  class AbstractParser
    def parse_command(text)
      return nil, nil
    end # method parse_command
  end # class
end # module
