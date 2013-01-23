# lib/parsers/simple_parser.rb

require 'parsers/abstract_parser'

module Mithril::Parsers
  class SimpleParser < AbstractParser
    def initialize(actions)
      raise ArgumentError.new "expected argument to respond to" +
        " :has_action?" unless actions.respond_to? :has_action?
      
      @actions = actions
    end # method initialize
    
    # Takes a string input and separates into words, then identifies a matching
    # action (if any) and remaining arguments. Returns both the command and the
    # arguments array, so usage can be as follows:
    #   command, args = parse_command(text)
    # 
    # === Parameters
    # * text: Expects a string composed of one or more words, separated by
    #   whitespace or hyphens.
    # 
    # === Returns
    # A two-element array consisting of the command and an array of the
    # remaining text arguments (if any), or [nil, args] if no matching action
    # was found.
    def parse_command(text)
      words = wordify preprocess_input text
      
      key  = nil
      args = []
      
      while 0 < words.count
        key = words.join('_').intern
        
        return key, args if @actions.has_action? key
        
        args.unshift words.pop
      end # while
      
      return nil, args
    end # method parse_command
  private
    def preprocess_input(text) # :doc:
      text.strip.downcase.
        gsub(/(\-+|\s+)/, ' ').
        gsub(/[\"?!-',.:\(\)\[\]\;]/, '')
    end # method preprocess_input
    
    #--
    # Wordify. Words fail me, or perhaps I have failed them.
    #++
    def wordify(text) # :doc:
      text.split(/\s+/)
    end # method wordify
  end # class
end # module
