# lib/controllers/mixins/mixins.rb

require 'mixin'
require 'controllers/controllers'

module Mithril::Controllers
  module Mixins
    module ActionMixin
      include ::Mixin
    
    private
      # Extends the mixin method to implement inheritance of @actions ivar.
      def mixin(source_module) # :doc:
        super
        
        self.mixins.each do |mixin|
          next unless source_module.respond_to? :actions
          if self.instance_variable_defined? :@actions
            source_module.actions.each do |key, value|
              @actions[key] = value
            end # each
          else
            @actions = source_module.actions.dup
          end # if-else
        end # each
      end # method mixin
    end # module
  end # module
end # module
