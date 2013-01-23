# lib/controllers/abstract_controller.rb

require 'controllers/controllers'
require 'controllers/mixins/actions_base'
require 'parsers/simple_parser'

module Mithril::Controllers
  # Base class for Mithril controllers. Extending controller functionality
  # can be implemented either through direct class inheritance, e.g.
  # 
  #   ModuleController > ProxyController > AbstractController
  # 
  # or through mixing in shared functionality with a Mixin, but all controllers
  # ought to extend AbstractController unless you have a very compelling reason
  # otherwise.
  class AbstractController
    extend Mithril::Controllers::Mixins::ActionMixin
    
    mixin Mithril::Controllers::Mixins::ActionsBase
    
    def initialize(request)
      raise ArgumentError.new "expected to be Mithril::Request" unless
        request.is_a? Mithril::Request
      @request = request
    end # constructor
    
    def class_name
      self.class.name.split("::").last
    end # accessor class_name
    private :class_name
    
    #########################
    ### Executing Actions ###
    
    def parser
      @parser ||= Mithril::Parsers::SimpleParser.new(self)
    end # method parser
    
    def parse_command(text)
      self.parser.parse_command text
    end # method parse_command
    
    # Returns true if this controller can process the input text into a command
    # and arguments. Otherwise returns false.
    def can_invoke?(text)
      self.allow_empty_action? || !self.parse_command(text).first.nil?
    end # method can_invoke?
    
    def command_missing(text)
      "I'm sorry, I don't know how to \"#{text}\". Please try another" +
        " command, or enter \"help\" for assistance."
    end # method command_missing
    
    # Evaluates text input in the context of the passed-in session. The text is
    # processed into a list of words, which are then matched against the
    # controller's actions to determine which action (if any) to invoke. The
    # matching is greedy, so "go to town" will match a :go_to action before it
    # will match "go".
    # 
    # If a match is found, the corresponding action is invoked with the session
    # and the remaining words as arguments. For example, if "go to town"
    # matched the :go_to action, then invoke_action(session, :go_to, ["town"])
    # would be called.
    # 
    # If the text does not match any commands and the allow_empty_action?
    # method evaluates to true, the empty action :"" is invoked with the full
    # arguments list. Otherwise, if a match is not found, returns a default
    # message string.
    # 
    # === Parameters
    # * session: Expects a hash (can be empty). Probably breaks if you pass in
    #   nil, or something that isn't a hash.
    # * text: Expects a string composed of one or more words, separated by
    #   whitespace or hyphens.
    # 
    # === Returns
    # The result of invoke_action, if an action was found (typically a string).
    # Otherwise returns a default message string.
    #--
    # === Steps for processing text input:
    # 
    # 1.  User or client sends text input.
    # 2.  Pre-process text input (strip, etc).
    # 3.  Split input into words.
    # 4.  Identify command and arguments.
    #     1.  Let len = words.count.
    #     2.  If 0 == len, goto 5.
    #     3.  For i = len, i >= 0, --i
    #         1.  Let command = words[0..i], arguments = words[i..len]
    #         2.  If command.snakify is an action, goto 6.
    # 5.  No valid command, return text output.
    # 6.  Let action = actions(command.snakify).
    # 7.  Output action[session, arguments]
    #++
    def invoke_command(text)
      # Mithril.logger.debug "AbstractController.invoke_command(), text =" +
      #   " #{text.inspect}"
      
      command, args = self.parse_command text
      
      if self.has_action? command
        self.invoke_action command, args
      elsif allow_empty_action?
        self.invoke_action :"", args
      else
        command_missing(text)
      end # unless-elsif
    end # method invoke_command
    
    # If this method evaluates to true, if the controller does not recognize an
    # action from the input text, it will attempt to invoke the empty action
    # :"" with the full arguments list.
    def allow_empty_action?
      false
    end # method allow_empty_action?
  end # class AbstractController
end # module
