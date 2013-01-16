# lib/controllers/spooky_controller.rb

require 'controllers/abstract_controller'
require 'controllers/mixins/help_actions'

module Mithril::Controllers
  class CallbackControllerError < StandardError
    # A hash of arrays. Each key corresponds to a callback that was attempted
    # to be set, and the array items the specific errors associated with that
    # callback.
    def errors
      @errors ||= {}
    end # method errors
  end # class CallbackControllerError
  
  # Why CallbackController? Because it does spooky action at a distance. Also,
  # because it scares me.
  class CallbackController < AbstractController
    mixin Mixins::HelpActions
    
    def controller?(ctr)
      ctr.is_a?(Class) && ctr <= Mithril::Controllers::AbstractController
    end # method controller
    private :controller?
    
    def resolve_controller(path) # :nodoc:
      return nil if path.nil? || 0 == path.length
      
      ns = Mithril::Controllers
      
      return nil unless ns.const_defined? path
      
      controller = ns.const_get path.intern
      return nil unless controller?(controller)
      
      controller
    end # method resolve_controller
    
    # Sets up a callback, parsing and storing the given parameters into the
    # session object. The routing controller is then responsible for detecting
    # a waiting callback and directing subsequent calls to the CallbackController
    # until the callback is cleared.
    # 
    # === Parameters
    # * session: Expects a hash. If the method is successful, this will be
    #   modified to store the stringified callback information.
    # * callbacks: Expects a hash. Each key should be a string or symbol, and
    #   each value should be a child hash with the following keys:
    #   * controller: Expects a Class extending AbstractController.
    #   * action: Expects a string or symbol. If this callback is selected, the
    #     CallbackController will attempt to invoke the specified action on the
    #     specified controller with the remaining arguments from the user's
    #     input.
    #   If anything goes wrong with parsing the hash, should raise a
    #   CallbackControllerError (see below).
    # 
    # === Raises
    # * CallbackControllerError
    #   * "empty callbacks hash": When supplied with a callbacks argument that
    #     is either nil or empty.
    #   * "malformed callbacks hash": When supplied with a callbacks argument
    #     that is malformed. The specific errors can be accessed via the
    #     CallbackControllerError errors method. To ease debugging, on finding a
    #     malformed callbacks hash, the method still iterates through the
    #     callbacks to identify all broken values, not just the first one it
    #     finds.
    # 
    # See also: deserialize_callbacks
    def serialize_callbacks(session, callbacks)
      if callbacks.nil? || callbacks.empty?
        raise CallbackControllerError.new "empty callbacks hash"
      end # if
      
      config, exception = {}, nil
      callbacks.each do |callback, params|
        controller = params[:controller]
        if controller.nil?
          exception ||= CallbackControllerError.new "malformed callbacks hash"
          (exception.errors[callback] ||= []) << "expected controller not to be nil"
        elsif !controller?(controller)
          exception ||= CallbackControllerError.new "malformed callbacks hash"
          (exception.errors[callback] ||= []) << "expected controller to extend AbstractController"
        end # if
        
        action = params[:action]
        if action.nil?
          exception ||= CallbackControllerError.new "malformed callbacks hash"
          (exception.errors[callback] ||= []) << "expected action not to be nil"
        end # if
        
        next unless exception.nil?
        
        ctr_string = controller.name.gsub(/^mithril::/i,'')
        ctr_string = ctr_string.gsub(/^controllers::/i,'')
        
        config[callback.to_s] = "#{ctr_string},#{action}"
      end # each
      
      if exception.nil?
        return config
      else
        raise exception
      end # if-else
    end # method serialize_callbacks
    
    # Extracts interned callback names, controller classes, and action keys
    # from a serialized callbacks object.
    # 
    # === Params
    # * session: Expects a hash. Raises an exception if nil, or if
    #   session[:callback] is nil or empty.
    # 
    # === Raises
    # * CallbackControllerError
    #   * "empty callbacks hash": When supplied with a session that is nil, or
    #     with a session[:callback] hash that is nil or empty.
    #   * "malformed callbacks hash": When supplied with a session[:callback]
    #     hash that is malformed. The specific errors can be accessed via the
    #     CallbackControllerError errors method.
    # 
    # See Also: serialize_callbacks
    def deserialize_callbacks(params)
      if params.nil? || params.empty?
        raise CallbackControllerError.new "empty callbacks hash"
      end # if
      
      callbacks, exception = {}, nil
      params.each do |key, value|
        callback = key.to_s
        if key.nil? || callback.empty?
          exception ||= CallbackControllerError.new "malformed callbacks hash"
          (exception.errors[callback] ||= []) << "expected callback not to be nil"
          next
        end # if
        
        segments = value.split ","
        
        ctr_string = segments.shift
        controller = self.resolve_controller ctr_string
        
        if controller.nil?
          exception ||= CallbackControllerError.new "malformed callbacks hash"
          (exception.errors[callback] ||= []) << "expected controller to extend AbstractController"
        end # if
        
        action = segments.shift
        if action.nil? || action.empty?
          exception ||= CallbackControllerError.new "malformed callbacks hash"
          (exception.errors[callback] ||= []) << "expected action not to be nil"
        end # if
        
        next unless exception.nil?
        
        callbacks[callback.intern] = { :controller => controller, :action => action.intern }
      end # each
      
      raise exception unless exception.nil?
      
      callbacks
    end # method parse_callback
    
    # Abstracts the details of retrieving the serialized callback from the
    # session object.
    def get_callbacks(session)
      return nil if session.nil?
      session[:callback]
    end # method get_callbacks
    
    # Abstracts the details of storing the serialized callback in the session
    # object.
    def set_callbacks(session, callback)
      return if session.nil?
      session[:callback] = callback
    end # method set_callbacks
    
    # Abstracts the details of removing a stored callback from the session
    # object.
    def clear_callbacks(session)
      session.delete :callback
    end # method clear_callbacks
    
    #=#=================#=#
    #=# ActionsBase API #=#
    
    # 
    def actions(allow_private = false)
      actions = super
      actions = actions.dup.update(@callbacks) unless @callbacks.nil? || @callbacks.empty?
      
      actions
    end # method actions
    
    def invoke_action(session, command, arguments, allow_private = false)\
      if @callbacks || !(callbacks = self.get_callbacks(session)).nil?
        callbacks = @callbacks || self.deserialize_callbacks(callbacks)
        
        unless (callback = callbacks[command]).nil?
          controller = callback[:controller]
          action     = callback[:action]
          
          self.clear_callbacks(session)
          
          return controller.new.invoke_action(session, action, arguments, true)
        end # if
      end # unless
      
      super
    end # method invoke_action
    
    def invoke_command(session, text)
      unless (callbacks = self.get_callbacks(session)).nil?
        @callbacks = self.deserialize_callbacks callbacks
      end # unless
      
      out = super
      
      @callbacks = nil
      
      out
    end # method invoke_command
  end # class CallbackController
end # module
