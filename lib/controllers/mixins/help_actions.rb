# lib/controllers/mixins/help_actions.rb

require 'controllers/mixins/actions_base'

module Mithril::Controllers::Mixins
  module HelpActions
    extend ActionMixin
    
    mixin ActionsBase
    
    def help_string
      ""
    end # method help_string
    
    define_action :help do |session, arguments|
      if arguments.first =~ /help/i
        return "The help command provides general assistance, or information" +
          " on specific commands.\n\nFormat: help COMMAND"
      end # if
      
      words = arguments.dup
      key   = nil
      
      while 0 < words.count
        cmd = words.join(' ')
        key = words.join('_').intern
        
        if self.respond_to?(:has_command?) && self.has_command?(cmd)
          return self.invoke_command "#{cmd} help"
        elsif self.has_action? key
          return self.invoke_action key, %w(help)
        end # if
        
        words.pop
      end # while
      
      str = 0 < self.help_string.length ? "#{self.help_string}\n\n" : ""
      
      names = self.respond_to?(:commands) ?
        self.commands :
        self.actions.map { |key, value| key.to_s.gsub('_',' ') }
      str += "The following commands are available: #{names.uniq.join(", ")}"
    end # action help
  end # module
end # module
