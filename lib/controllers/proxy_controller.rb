# lib/controllers/proxy_controller.rb

require 'controllers/abstract_controller'

module Mithril::Controllers
  # Redirects incoming commands to a proxy controller based on the :proxy
  # method. If no proxy is present, evaluates commands as normal.
  class ProxyController < AbstractController
    # The proxy controller to which commands are redirected. Must be
    # overriden in subclasses.
    def proxy
      # override this in sub-classes
    end # method proxy
    
    # Returns actions defined on this controller or on ancestors.
    alias_method :own_actions, :actions
    
    # If evalutes to true, then any actions defined on this controller will be
    # available even when a proxy is present. However, if both this controller
    # and the proxy define the same action, then the proxy's version will be
    # invoked. Defaults to true, but can be overriden in subclasses.
    def allow_own_actions_while_proxied?
      true
    end # method allow_own_actions_while_proxied?
    
    # If no proxy is defined, returns own actions. If a proxy is defined,
    # returns all actions defined on the proxy. Alternatively, if
    # allow_own_actions_while_proxied? evaluates to true, returns all
    # actions defined either on this controller or on the proxy.
    def actions
      if self.proxy.nil?
        super
      elsif self.allow_own_actions_while_proxied?
        super.update(proxy.actions)
      else
        proxy.actions
      end # if-elsif-else
    end # method actions
    
    # As has_action?, but returns true iff the action is defined on this
    # controller or its ancestors.
    def has_own_action?(key)
      return false if key.nil?
      return self.own_actions.has_key? key.intern
    end # method has_own_action?
    
    # If no proxy is present, attempts to invoke the action on self. If a proxy
    # is present and has the specified action, invokes the action on the proxy.
    # Otherwise, attempts to invoke action on self iff
    # allow_own_actions_while_proxied? evaluates to true.
    def invoke_action(session, command, args)
      if self.proxy.nil?
        super
      elsif self.proxy.has_action? command
        proxy.invoke_action session, command, args
      elsif self.allow_own_actions_while_proxied?
        super
      end # if-elsif-else
    end # method invoke_action
  end # class ProxyController
end # module
