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
    include source_module
    
    return unless source_module.respond_to? :mixins
    
    self.mixins = source_module.mixins.dup || []
    self.mixins << source_module
    
    self.mixins.each do |mixin|
      if mixin.const_defined? :ClassMethods
        extend mixin::ClassMethods
      end # if
    end # each
  end # method mixin
end # module Mixin
