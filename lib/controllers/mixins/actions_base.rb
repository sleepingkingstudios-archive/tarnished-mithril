# lib/controllers/mixins/actions_base.rb

require 'controllers/mixins/mixins'

module Mithril::Controllers::Mixins
  # Core functions for implementing a command+args response model. ActionsBase
  # should be mixed in to controllers, either directly or via an intermediate
  # Mixin that implements default or shared actions.
  module ActionsBase
    extend ActionMixin
    
    # These methods get extend-ed into the class of the controller through the
    # magic of Mixin.
    module ClassMethods
      # Defines an action to which the controller will respond.
      # 
      # === Parameters
      # * key: Expects a string or symbol. Best practice is to use snake_case,
      #   e.g. all lower-case letters, with words separated by underscores. It
      #   *ought* to work anyway, but caveat lector.
      # * params: Optional. Expects a hash of configuration values.
      #   * private: If set to true, creates a private action. Private actions
      #     are not listed by "help" and cannot be invoked directly by the
      #     user. They can be used to set up internal APIs.
      # * &block: The procedure to run when the action is invoked. Must accept
      #   two arguments: a session hash and an arguments list.
      def define_action(key, params = {}, &block)
        key = key.to_s.downcase.gsub(/\s+|\-+/,'_').intern
        
        define_method :"action_#{key}", &block
        
        @actions ||= {}
        @actions[key] = params
      end # class method define_action
      
      # Lists the actions defined for the current controller by its base class.
      # In most cases, the actions instance method should be used instead, as
      # it handles class-based inheritance and can be overriden to implement
      # controller-specific functionality, such as proxies or delegates.
      def actions(allow_private = false)
        actions = @actions ||= {}
        
        unless allow_private
          actions = actions.select { |key, action| !action.has_key? :private }
        end # unless
        
        actions
      end # class method actions
    end # module ClassMethods
    
    attr_reader :request
    
    # Lists the actions available to the current controller. Override this
    # method to implement action redirection, e.g. through a proxy or delegate.
    def actions(allow_private = false)
      actions = {}
      
      actions.update(self.class.superclass.actions(allow_private)) if (klass = self.class.superclass).respond_to? :actions
      
      actions.update(self.class.actions(allow_private))
      
      actions
    end # method actions
    
    # Wrapper method for actions.has_key?
    def has_action?(key, allow_private = false)
      return false if key.nil?
      
      self.actions(allow_private).has_key? key.intern
    end # method has_action?
    
    # Searches for a matching action. If found, calls the action with the given
    # session hash and arguments list.
    # 
    # === Parameters
    # * session: Expects a hash (can be empty). Probably breaks if you pass in
    #   nil, or something that isn't a hash.
    # * command: Converted to a string. The converted string must be an exact
    #   match (===) to the key passed in to klass.define_action.
    # * args: Expects an array (can be empty). Probably breaks if you pass in
    #   nil, or something that isn't an array.
    # * allow_private: Expects true or false. If true, can invoke private
    #   actions. Defaults to false.
    # 
    # === Returns
    # The result of the action (should be a string), or nil if no action was
    # invoked.
    def invoke_action(command, args, allow_private = false)
      session = request ? request.session || {} : {}
      if self.has_action? command, allow_private
        self.send :"action_#{command}", session, args
      else
        nil
      end # if-else
    end # method invoke_action
  end # module ActionsBase
end # module
