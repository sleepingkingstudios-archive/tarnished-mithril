# lib/controllers/mixins/callback_helpers.rb

require 'controllers/abstract_controller'
require 'controllers/mixins/mixins'
require 'errors/callback_error'
require 'ingots/ingots'

module Mithril::Controllers::Mixins
  module CallbackHelpers
    extend ActionMixin
    
    include Mithril::Errors
    
    def controller?(ctr) # :nodoc:
      ctr.is_a?(Class) && ctr <= Mithril::Controllers::AbstractController
    end # method controller
    
    def resolve_controller(path) # :nodoc:
      return nil if path.nil? || 0 == path.length
      
      segments = path.split(':')
      
      # Try and resolve a controller in the core namespace.
      ns = Mithril::Controllers
      if ns.const_defined? segments.first
        controller = ns.const_get segments.first.intern
        return controller if controller?(controller)
      end # if
      
      # Try and resolve a controller in a module namespace.
      ns = Mithril::Ingots
      return nil unless ns.const_defined? segments.first
      
      ns = ns.const_get segments.shift.intern
      return nil unless ns.is_a? Module
      return nil unless ns.const_defined? :Controllers
      
      ns = ns.const_get :Controllers
      return nil unless ns.is_a? Module
      
      if ns.const_defined? segments.first
        controller = ns.const_get segments.first.intern
        return controller if controller?(controller)
      end # if
      
      nil
    end # method resolve_controller
    
    # Sets up a callback, parsing the given parameters into a hash of strings
    # that should be safe for storing in a session.
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
    #   CallbackError (see below).
    # 
    # === Raises
    # * CallbackError
    #   * "empty callbacks hash": When supplied with a callbacks argument that
    #     is either nil or empty.
    #   * "malformed callbacks hash": When supplied with a callbacks argument
    #     that is malformed. The specific errors can be accessed via the
    #     CallbackError errors method. To ease debugging, on finding a
    #     malformed callbacks hash, the method still iterates through the
    #     callbacks to identify all broken values, not just the first one it
    #     finds.
    # 
    # See also: deserialize_callbacks
    def serialize_callbacks(callbacks)
      if callbacks.nil? || callbacks.empty?
        raise CallbackError.new "empty callbacks hash"
      end # if
      
      config, exception = {}, nil
      callbacks.each do |callback, params|
        controller = params[:controller]
        if controller.nil?
          exception ||= CallbackError.new "malformed callbacks hash"
          (exception.errors[callback] ||= []) << "expected controller not to be nil"
        elsif !controller?(controller)
          exception ||= CallbackError.new "malformed callbacks hash"
          (exception.errors[callback] ||= []) << "expected controller to extend AbstractController"
        end # if
        
        action = params[:action]
        if action.nil?
          exception ||= CallbackError.new "malformed callbacks hash"
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
    # * CallbackError
    #   * "empty callbacks hash": When supplied with a session that is nil, or
    #     with a session[:callback] hash that is nil or empty.
    #   * "malformed callbacks hash": When supplied with a session[:callback]
    #     hash that is malformed. The specific errors can be accessed via the
    #     CallbackError errors method.
    # 
    # See Also: serialize_callbacks
    def deserialize_callbacks(params)
      if params.nil? || params.empty?
        raise CallbackError.new "empty callbacks hash"
      end # if
      
      callbacks, exception = {}, nil
      params.each do |key, value|
        callback = key.to_s
        if key.nil? || callback.empty?
          exception ||= CallbackError.new "malformed callbacks hash"
          (exception.errors[callback] ||= []) << "expected callback not to be nil"
          next
        end # if
        
        segments = value.split ","
        
        ctr_string = segments.shift
        controller = self.resolve_controller ctr_string
        
        if controller.nil?
          exception ||= CallbackError.new "malformed callbacks hash"
          (exception.errors[callback] ||= []) << "expected controller to extend AbstractController"
        end # if
        
        action = segments.shift
        if action.nil? || action.empty?
          exception ||= CallbackError.new "malformed callbacks hash"
          (exception.errors[callback] ||= []) << "expected action not to be nil"
        end # if
        
        next unless exception.nil?
        
        callbacks[callback.intern] = { :controller => controller, :action => action.intern }
      end # each
      
      raise exception unless exception.nil?
      
      callbacks
    end # method deserialize_callback
    
    def callback_key
      :callback
    end # method callback_key
    private :callback_key
    
    # Abstracts the details of retrieving the serialized callback from the
    # session object.
    def get_callbacks(session)
      return nil if session.nil?
      session[callback_key]
    end # method get_callbacks
    
    # Abstracts the details of storing the serialized callback in the session
    # object.
    def set_callbacks(session, callback)
      return if session.nil?
      session[callback_key] = callback
    end # method set_callbacks
    
    # Abstracts the details of removing a stored callback from the session
    # object.
    def clear_callbacks(session)
      session.delete callback_key
    end # method clear_callbacks
    
    # Returns true if there is a stored callback in the session object;
    # otherwise returns false.
    def has_callbacks?(session)
      session.has_key? callback_key
    end # method has_callbacks?
  end # module
end # module
