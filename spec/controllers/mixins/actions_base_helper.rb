# spec/controllers/mixins/actions_base_helper.rb

require 'spec_helper'
require 'controllers/mixins/actions_base'

require 'request'

module Mithril
  module Mock; end
end # module

shared_examples_for Mithril::Controllers::Mixins::ActionsBase do
  let :command do :test; end
  let :params  do { :bar => :baz }; end
  
  it { instance.should_not respond_to :"action_#{command}" }
  
  describe "self.define_action" do
    it { described_class.should respond_to :define_action }
    
    it { expect { described_class.define_action }.to raise_error ArgumentError,
      /wrong number of arguments/i }
    
    it { expect { described_class.define_action command }.to raise_error ArgumentError,
      /without a block/i }
      
    it { expect { described_class.define_action command, params }.to raise_error ArgumentError,
      /without a block/i }
      
    it { expect { described_class.define_action command do; end }.not_to raise_error }
    
    it { expect { described_class.define_action command, params do; end }.not_to raise_error }
  end # describe
  
  describe "self.actions" do
    it { described_class.should respond_to :actions }
    
    it { described_class.actions.should be_a Hash }
    
    it { expect { described_class.actions }.not_to raise_error }
    it { expect { described_class.actions(true) }.not_to raise_error }
  end # describe actions
  
  describe :request do
    it { instance.should respond_to :request }
    it { expect { instance.request }.not_to raise_error }
    it { instance.request.should be_a Mithril::Request unless instance.request.nil? }
  end # describe request
  
  describe :actions do
    it { instance.should respond_to :actions }
    
    it { instance.actions.should be_a Hash }
    
    it { expect { instance.actions }.not_to raise_error }
    it { expect { instance.actions(true) }.not_to raise_error }
  end # describe
  
  describe :has_action? do
    it { instance.should respond_to :has_action? }
    
    it { expect { instance.has_action? }.to raise_error ArgumentError,
      /wrong number of arguments/i }
    
    it { expect { instance.has_action? :command }.not_to raise_error }
    
    it { expect { instance.has_action? :command, true }.not_to raise_error }
    
    it { instance.has_action?(command).should be false }
    it { instance.has_action?(command, true).should be false }
  end # describe has_action?
  
  describe :invoke_action do
    let :command   do :foo; end
    let :arguments do []; end

    it { instance.should respond_to :invoke_action }

    it { expect { instance.invoke_action }.to raise_error ArgumentError,
      /wrong number of arguments/i }

    it { expect { instance.invoke_action command }.to raise_error ArgumentError,
      /wrong number of arguments/i }

    it { expect { instance.invoke_action command, arguments }.not_to raise_error }
    
    it { expect { instance.invoke_action command, arguments, true }.not_to raise_error }
  end # describe invoke_action
  
  context :has_defined_action do
    before :each do
      described_class.define_action command, params do |session, args| args.join(" "); end
    end # before each
    
    it { instance.should respond_to :"action_#{command}" }
    
    describe :has_action? do
      it { instance.has_action?(command).should be true }
      it { instance.has_action?(command, true).should be true }
    end # describe has_action?
    
    describe "self.actions" do
      it { described_class.actions.should include command }
      it { described_class.actions(true).should include command }
    end # describe self.actions
    
    describe "actions" do
      it { instance.actions.should include command }
      it { instance.actions(true).should include command }
    end # describe actions
    
    describe :invoke_action do
      let :request do defined?(super) ? super() : FactoryGirl.build(:request); end
      let :arguments do %w(some args); end
      
      before :each do instance.stub :request do request; end; end
      
      it "invokes the action" do
        instance.should_receive(:"action_#{command}").with(request.session, arguments).and_call_original
        instance.invoke_action command, arguments
      end # it
      
      it "invokes the action as a private action" do
        instance.should_receive(:"action_#{command}").with(request.session, arguments).and_call_original
        instance.invoke_action command, arguments, true
      end # it
      
      it { instance.invoke_action(command, arguments).should eq arguments.join(" ") }
      it { instance.invoke_action(command, arguments, true).should eq arguments.join(" ") }
    end # describe
  end # context
  
  describe "private actions" do
    let :command do :secret; end
    let :params  do { :private => true }; end
    
    context "with a private action defined" do
      before :each do
        described_class.define_action command, params do |session, args| args.join(" "); end
      end # before each
      
      it { instance.should respond_to :"action_#{command}" }
      
      describe "self.actions" do
        it { described_class.actions.should_not include command }
        it { described_class.actions(true).should include command }
      end # describe self.actions
      
      describe "actions" do
        it { instance.actions.should_not include command }
        it { instance.actions(true).should include command }
      end # describe
      
      describe :has_action? do
        it { instance.has_action?(command).should be false }
        it { instance.has_action?(command, true).should be true }
      end # describe has_action?
      
      describe :invoke_action do
        let :request do defined?(super) ? super() : FactoryGirl.build(:request); end
        let :arguments do %w(some args); end
        
        before :each do instance.stub :request do request; end; end

        it "does not invoke the action" do
          instance.should_not_receive(:"action_#{command}")
          instance.invoke_action command, arguments
        end # it
        
        it "invokes the action as a private action" do
          instance.should_receive(:"action_#{command}").with(request.session, arguments).and_call_original
          instance.invoke_action command, arguments, true
        end # it

        it { instance.invoke_action(command, arguments).should be nil }
        it { instance.invoke_action(command, arguments, true).should eq arguments.join(" ") }
      end # describe
    end # context
  end # describe
end # shared examples Mithril::Controllers::Mixins::ActionBase
