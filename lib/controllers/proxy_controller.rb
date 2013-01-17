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
    # and the proxy define the same action, then the parent's version will be
    # invoked. Defaults to true, but can be overriden in subclasses.
    def allow_own_actions_while_proxied?
      true
    end # method allow_own_actions_while_proxied?
    
    # If no proxy is defined, returns own actions. If a proxy is defined,
    # returns all actions defined on the proxy. Alternatively, if
    # allow_own_actions_while_proxied? evaluates to true, returns all
    # actions defined either on this controller or on the proxy.
    def actions(allow_private = false)
      if self.proxy.nil?
        super
      elsif self.allow_own_actions_while_proxied?
        proxy.actions(allow_private).dup.update(super)
      else
        proxy.actions(allow_private)
      end # if-elsif-else
    end # method actions
    
    # As has_action?, but returns true iff the action is defined on this
    # controller or its ancestors.
    def has_own_action?(key, allow_private = false)
      return false if key.nil?
      return self.own_actions(allow_private).has_key? key.intern
    end # method has_own_action?
    
    # If no proxy is present, attempts to invoke the action on self. If a proxy
    # is present and the parent defines that command and
    # allow_own_actions_while_proxied? evaluates to true, attempts to invoke
    # the action on self. Otherwise, if the proxy defines that command, invokes
    # the action on the proxy.
    # 
    # This precedence order was selected to allow reflection within actions,
    # e.g. the help action in Mixins::HelpActions that lists all available
    # actions.
    def invoke_action(command, arguments, allow_private = false)
      if self.proxy.nil?
        out = super
      elsif self.allow_own_actions_while_proxied?() && self.has_own_action?(command, allow_private)
        out = super
      elsif self.proxy.has_action? command, allow_private
        out = proxy.invoke_action command, arguments, allow_private
      end # if-elsif-else
    end # method invoke_action
  end # class ProxyController
end # module
