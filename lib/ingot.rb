# lib/ingot.rb

require 'mithril'

module Mithril
  # An interactive module for the Mithril text engine. The Ingot class
  # registers the module so it can be selected within the engine. Once
  # selected by a logged-in user, input commands and output will be routed
  # through an instance of the Ingot's controller property.
  class Ingot
    class << self
      # Creates a new module and adds it to the registry. This function should
      # be called preferentially to :new except during testing.
      # 
      # === Parameters
      # * key: Unique identifier for the module. A string or symbol is probably
      #   best.
      # * controller: The root controller for the module. When the module is
      #   selected, all text input and output will route through an instance of
      #   this controller. Must be a Class that extends AbstractController or
      #   mimics its API.
      # * params: Optional. Expects a hash. Currently supported options:
      #   * name: Expects a string. A human-friendly string name for the
      #     module. If omitted, is automatically generated from the module key.
      def create(key, controller, params = {})
        key = key.to_s.downcase.gsub(/\s+/,'_').intern
        (@modules ||= {})[key] = new(key, controller, params)
      end # class method create
      
      # Returns an array containing all defined modules.
      def all
        @modules ||= {}
      end # class method all
      
      # Returns true if a module is defined with the given key; otherwise
      # returns false.
      def exists?(key)
        key = key.to_s.downcase.gsub(/\s+/,'_').intern
        self.all.has_key? key
      end # class method exists
      
      # If a module is defined with the given key, returns the module;
      # otherwise returns nil.
      def find(key)
        key = key.to_s.downcase.gsub(/\s+/,'_').intern
        self.all[key]
      end # class method find
    end # class << self
    
    def initialize(key, controller, params = {})
      key = key.to_s.downcase.gsub(/\s+/,'_').intern
      
      @module_key = key
      @controller = controller
      @name = params[:name] || @module_key.to_s.gsub('_',' ')
    end # method initialize
    
    # Returns the module key.
    def key
      @module_key
    end # method key
    
    # Returns the module controller. This should be a Class, not an instance.
    def controller
      @controller
    end # method controller
    
    # Returns the user-friendly name of the string.
    def name
      @name
    end # method name
  end # class Ingot
end # module Mithril
