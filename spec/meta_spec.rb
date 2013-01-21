# spec/meta_spec

require 'factory_girl'

require 'mixin'

class Dependency
  def initialize
    @@id ||= -1
    @id ||= (@@id += 1)
    
    # puts "Dependency.initialize(), id = #{self.id}"
  end # method initialize
  
  attr_reader :id
end # class

FactoryGirl.define do
  factory :dependency do; end
end # define

module HelperModule
  def helper_method; end
end # module

module MixinModule
  extend Mixin
  
  def mixin_method; dependency; end
end # module

module MixinWithHelperModule
  include HelperModule
  extend Mixin
  
  mixin MixinModule
end # module

class BaseClass
  extend Mixin
  
  def initialize(requirement); end
  
  def dependency; end
end # class

class BaseClassWithHelper < BaseClass
  include HelperModule
end # class

class BaseClassWithMixin < BaseClass
  mixin MixinModule
end # class

class ExtendedClass < BaseClass
  mixin MixinModule
  
  def extended_method; end
end # class

class ExtendedClassWithMixinAndHelper < ExtendedClass
  mixin MixinWithHelperModule
  
  def another_method; end
end # class

shared_examples_for HelperModule do
  it { instance.should respond_to :helper_method }
end # shared examples

shared_examples_for MixinModule do
  it { instance.should respond_to :mixin_method }
  it { expect { instance.mixin_method }.not_to raise_error }
end # shared examples

shared_examples_for MixinWithHelperModule do
  it_behaves_like HelperModule
  it_behaves_like MixinModule
end # shared examples

shared_examples_for BaseClass do
  it { instance.should respond_to :dependency }
end # shared examples

describe HelperModule do
  let :described_class do Class.new.send :include, super(); end
  let :instance do described_class.new; end
  
  it_behaves_like HelperModule
end # describe Helper

describe MixinModule do
  let :described_class do Class.new.send :include, super(); end
  let :instance do described_class.new.tap do |i|
    i.stub :dependency do FactoryGirl.build :dependency;
  end; end; end
  
  it_behaves_like MixinModule
end # describe MixinModule

describe MixinWithHelperModule do
  let :described_class do Class.new.send :include, super(); end
  let :instance do described_class.new.tap do |i|
    i.stub :dependency do FactoryGirl.build :dependency;
  end; end; end
  
  it_behaves_like HelperModule
  it_behaves_like MixinModule
end # describe MixinWithHelperModule

describe BaseClass do
  let :described_class do Class.new super(); end
  let :instance do described_class.new FactoryGirl.build :dependency; end
  
  it_behaves_like BaseClass
end # describe BaseClass

describe BaseClassWithHelper do
  let :described_class do Class.new super(); end
  let :instance do described_class.new FactoryGirl.build :dependency; end
  
  it_behaves_like BaseClass
  it_behaves_like HelperModule
end # describe BaseClassWithHelper

describe BaseClassWithMixin do
  let :described_class do Class.new super(); end
  let :instance do described_class.new FactoryGirl.build :dependency; end
  
  it_behaves_like BaseClass
  it_behaves_like MixinModule
end # describe

describe ExtendedClassWithMixinAndHelper do
  let :described_class do Class.new super(); end
  let :instance do described_class.new FactoryGirl.build :dependency; end
  
  it_behaves_like BaseClass
  it_behaves_like HelperModule
  it_behaves_like MixinModule
  
  it { instance.should respond_to :another_method }
end # describe
