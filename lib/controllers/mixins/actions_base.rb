# lib/controllers/mixins/actions_base.rb

require 'controllers/mixins/mixins'

module Mithril::Controllers::Mixins
  module ActionsBase
    extend ActionMixin
    
    module ClassMethods
      def define_action(key, params = {}, &block)
        key = key.to_s.downcase.gsub(/\s+|\-+/,'_').intern
        
        params[:method_name] ||= :"action_#{key}"
        
        define_method params[:method_name], &block
        
        @actions ||= {}
        @actions[key] = params
      end # class method define_action
      
      def actions
        @actions ||= {}
      end # class method actions
    end # module ClassMethods
    
    def actions
      actions = {}
      
      actions.update(self.class.superclass.actions) if (klass = self.class.superclass).respond_to? :actions
      
      actions.update(self.class.actions)
      
      actions
    end # method actions
    
    def has_action?(key)
      return false if key.nil?
      return self.actions.has_key? key.intern
    end # method has_action?

    def invoke_action(session, command, args)
      if self.has_action? command
        self.send :"action_#{command}", session, args
      else
        nil
      end # if-else
    end # method invoke_action
  end # module ActionsBase
end # module
