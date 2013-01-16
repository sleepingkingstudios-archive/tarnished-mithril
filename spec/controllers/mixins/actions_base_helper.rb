# spec/controllers/mixins/actions_base_helper.rb

require 'spec_helper'
require 'controllers/mixins/actions_base'

module Mithril
  module Mock; end
end # module

shared_examples_for Mithril::Controllers::Mixins::ActionsBase do
  before :each do
    if described_class.is_a? Class
      Mithril::Mock.const_set :MockActions, Class.new(described_class)
    elsif described_class.is_a? Module
      klass = Class.new
      klass.send :extend, Mithril::Controllers::Mixins::ActionMixin
      klass.send :mixin,  described_class
      
      Mithril::Mock.const_set :MockActions, klass
    end # if-elsif
  end # before each
  
  after :each do
    Mithril::Mock.send :remove_const, :MockActions
  end # after all
  
  let :actionable do Mithril::Mock::MockActions; end
  let :instance   do actionable.new; end
  
  let :action_name   do :test; end
  let :action_params do { :bar => :baz }; end
  
  it { instance.should_not respond_to :"action_#{action_name}" }
  
  describe "self.define_action" do
    it { actionable.should respond_to :define_action }
    
    it { expect { actionable.define_action }.to raise_error ArgumentError,
      /wrong number of arguments/i }
    
    it { expect { actionable.define_action action_name }.to raise_error ArgumentError,
      /without a block/i }
      
    it { expect { actionable.define_action action_name, action_params }.to raise_error ArgumentError,
      /without a block/i }
      
    it { expect { actionable.define_action action_name do; end }.not_to raise_error }
    
    it { expect { actionable.define_action action_name, action_params do; end }.not_to raise_error }
  end # describe
  
  describe "self.actions" do
    it { actionable.should respond_to :actions }
    
    it { actionable.actions.should be_a Hash }
    
    it { expect { actionable.actions }.not_to raise_error }
    it { expect { actionable.actions(true) }.not_to raise_error }
  end # describe actions
  
  describe "actions" do
    it { instance.should respond_to :actions }
    
    it { instance.actions.should be_a Hash }
    
    it { expect { instance.actions }.not_to raise_error }
    it { expect { instance.actions(true) }.not_to raise_error }
  end # describe
  
  describe :has_action? do
    it { instance.should respond_to :has_action? }
    
    it { expect { instance.has_action? }.to raise_error ArgumentError,
      /wrong number of arguments/i }
    
    it { expect { instance.has_action? :action_name }.not_to raise_error }
    
    it { expect { instance.has_action? :action_name, true }.not_to raise_error }
    
    it { instance.has_action?(action_name).should be false }
    it { instance.has_action?(action_name, true).should be false }
  end # describe has_action?
  
  describe :invoke_action do
    let :session   do {}; end
    let :command   do :foo; end
    let :arguments do []; end

    it { instance.should respond_to :invoke_action }

    it { expect { instance.invoke_action }.to raise_error ArgumentError,
      /wrong number of arguments/i }

    it { expect { instance.invoke_action session }.to raise_error ArgumentError,
      /wrong number of arguments/i }

    it { expect { instance.invoke_action session, command }.to raise_error ArgumentError,
      /wrong number of arguments/i }

    it { expect { instance.invoke_action session, command, arguments }.not_to raise_error }
    
    it { expect { instance.invoke_action session, command, arguments, true }.not_to raise_error }
  end # describe invoke_action
  
  context :has_defined_action do
    before :each do
      actionable.define_action action_name, action_params do |session, args| args.join(" "); end
    end # before each
    
    it { instance.should respond_to :"action_#{action_name}" }
    
    describe :has_action? do
      it { instance.has_action?(action_name).should be true }
      it { instance.has_action?(action_name, true).should be true }
    end # describe has_action?
    
    describe "self.actions" do
      it { actionable.actions.should include action_name }
      it { actionable.actions(true).should include action_name }
    end # describe self.actions
    
    describe "actions" do
      it { instance.actions.should include action_name }
      it { instance.actions(true).should include action_name }
    end # describe actions
    
    describe :invoke_action do
      let :session     do {}; end
      let :action_args do %w(some args); end
      
      it "invokes the action" do
        instance.should_receive(:"action_#{action_name}").with(session, action_args).and_call_original
        instance.invoke_action session, action_name, action_args
      end # it
      
      it "invokes the action as a private action" do
        instance.should_receive(:"action_#{action_name}").with(session, action_args).and_call_original
        instance.invoke_action session, action_name, action_args, true
      end # it
      
      it { instance.invoke_action(session, action_name, action_args).should eq action_args.join(" ") }
      it { instance.invoke_action(session, action_name, action_args, true).should eq action_args.join(" ") }
    end # describe
  end # context
  
  describe "private actions" do
    let :action_name   do :secret; end
    let :action_params do { :private => true }; end
    
    context "with a private action defined" do
      before :each do
        actionable.define_action action_name, action_params do |session, args| args.join(" "); end
      end # before each
      
      it { instance.should respond_to :"action_#{action_name}" }
      
      describe "self.actions" do
        it { actionable.actions.should_not include action_name }
        it { actionable.actions(true).should include action_name }
      end # describe self.actions
      
      describe "actions" do
        it { instance.actions.should_not include action_name }
        it { instance.actions(true).should include action_name }
      end # describe
      
      describe :has_action? do
        it { instance.has_action?(action_name).should be false }
        it { instance.has_action?(action_name, true).should be true }
      end # describe has_action?
      
      describe :invoke_action do
        let :session     do {}; end
        let :action_args do %w(some args); end

        it "does not invoke the action" do
          instance.should_not_receive(:"action_#{action_name}")
          instance.invoke_action session, action_name, action_args
        end # it
        
        it "invokes the action as a private action" do
          instance.should_receive(:"action_#{action_name}").with(session, action_args).and_call_original
          instance.invoke_action session, action_name, action_args, true
        end # it

        it { instance.invoke_action(session, action_name, action_args).should be nil }
        it { instance.invoke_action(session, action_name, action_args, true).should eq action_args.join(" ") }
      end # describe
    end # context
  end # describe
end # shared examples Mithril::Controllers::Mixins::ActionBase
