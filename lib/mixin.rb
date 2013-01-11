# lib/mixin.rb

# Implements module-based inheritance of both class- and instance-level
# methods.

module Mixin
  def mixins
    @mixins ||= []
  end # accessor mixins
  
  def mixins=(ary)
    @mixins = ary
  end # mutator mixins
  
private
  # Alternative to Module.extend that also provides inheritance of class-level
  # methods defined through an (optional) ClassMethods module.
  def mixin(source_module) # :doc:
    Mithril.logger.debug "#{self.class.name}.mixin, source = #{source_module}" +
      ", methods = #{source_module.methods - Object.methods}"
    
    include source_module
    
    return unless source_module.respond_to? :mixins
    
    self.mixins = source_module.mixins.dup || []
    self.mixins << source_module
    
    Mithril.logger.debug "mixins = #{self.mixins}"
    
    self.mixins.each do |mixin|
      if mixin.const_defined? :ClassMethods
        extend mixin::ClassMethods
      end # if
    end # each
  end # method mixin
end # module Mixin
