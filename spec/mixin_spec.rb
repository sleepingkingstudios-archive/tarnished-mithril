# spec/mixin_spec.rb

require 'spec_helper'
require 'mixin'

module Mithril
  module Mock; end
end # module

describe Mixin do
  before :each do
    foo = Module.new
    foo.send :extend, Mixin
    foo.send :define_method, :foo do; end
    
    Mithril::Mock.const_set :Foo, foo
    
    foo_m = Module.new
    foo_m.send :define_method, :foo_m do; end
    
    Mithril::Mock::Foo.const_set :ClassMethods, foo_m
    
    bar = Module.new
    bar.send :extend, Mixin
    bar.send :mixin, Mithril::Mock::Foo
    bar.send :define_method, :bar do; end
    
    Mithril::Mock.const_set :Bar, bar
    
    bar_m = Module.new
    bar_m.send :define_method, :bar_m do; end
    
    Mithril::Mock::Bar.const_set :ClassMethods, bar_m
    
    baz = Class.new
    baz.send :extend, Mixin
    baz.send :mixin, Mithril::Mock::Bar
    
    Mithril::Mock.const_set :Baz, baz
  end # before each
  
  after :each do
    Mithril::Mock.send :remove_const, :Foo
    Mithril::Mock.send :remove_const, :Bar
    Mithril::Mock.send :remove_const, :Baz
  end # after each
  
  let :described_class do Mithril::Mock::Baz; end
  let :instance do described_class.new; end
  
  it { Mithril::Mock::Bar.should respond_to :foo_m }
  it { expect {
    module Mithril::Mock::Bar
      foo_m
    end # module
  }.not_to raise_error }
  
  it { described_class.should respond_to :foo_m }
  it { instance.should respond_to :foo }
  
  it { described_class.should respond_to :bar_m }
  it { instance.should respond_to :bar }
end # describe
