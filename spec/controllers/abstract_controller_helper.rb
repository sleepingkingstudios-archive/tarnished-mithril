# spec/controllers/abstract_controller_helper.rb

require 'spec_helper'
require 'controllers/mixins/actions_base_helper'

require 'controllers/abstract_controller'
require 'parsers/abstract_parser'
require 'request'

shared_examples_for Mithril::Controllers::AbstractController do
  it_behaves_like Mithril::Controllers::Mixins::ActionsBase
  
  describe :constructor do
    it { expect { described_class.new }.to raise_error ArgumentError,
      /wrong number of arguments/i }
    it { expect { described_class.new nil }.to raise_error ArgumentError,
      /expected to be Mithril::Request/i }
    it { expect { described_class.new request }.not_to raise_error }
  end # describe constructor
  
  describe :parser do
    it { expect(instance).to respond_to :parser }
    it { expect { instance.parser }.not_to raise_error }
    it { expect(instance.parser).to be_a Mithril::Parsers::AbstractParser }
  end # describe
  
  describe :parse_command do
    let :parser do instance.parser; end
    let :text do "some text"; end
    
    it { expect(instance).to respond_to :parse_command }
    it { expect { instance.parse_command }.to raise_error ArgumentError,
      /wrong number of arguments/i }
    it { expect { instance.parse_command text }.not_to raise_error }
    it { expect(instance.parse_command text).to be_a Array }
    
    it "delegates to the parser" do
      parser.should_receive(:parse_command).with(text)
      instance.parse_command text
    end # it
  end # describe parse_command
  
  describe :command_missing do
    let :text do "some text"; end
    
    it { instance.should respond_to :command_missing }
    it { expect { instance.command_missing }.to raise_error ArgumentError,
      /wrong number of arguments/i }
    it { expect { instance.command_missing(text).not_to raise_error } }
    it { instance.command_missing(text).should =~ /don't know how/ }
    it { instance.command_missing(text).should =~ /#{text}/ }
  end # describe
  
  describe :commands do
    it { expect(instance).to respond_to :commands }
    it { expect { instance.commands }.not_to raise_error }
    it { expect(instance.commands).to be_a Array }
  end # describe commands
  
  describe :has_command? do
    it { expect(instance).to respond_to :has_command? }
    it { expect { instance.has_command? }.to raise_error ArgumentError,
      /wrong number of arguments/i }
    it { expect { instance.has_command? "" }.not_to raise_error }
    it { expect(instance.has_command? "").to be false }
  end # describe has_command?
  
  describe :can_invoke? do
    let :text do "some text"; end
    
    it { instance.should respond_to :can_invoke? }
    it { expect { instance.can_invoke? }.to raise_error ArgumentError,
      /wrong number of arguments/i }
    it { expect { instance.can_invoke? text }.not_to raise_error }
    it { instance.can_invoke?(text).should be false }
  end # describe can_invoke?
  
  describe :invoke_command do
    let :text do ""; end
    
    it { instance.should respond_to :invoke_command }
    
    it { expect { instance.invoke_command }.to raise_error ArgumentError,
      /wrong number of arguments/i }
    
    it { expect { instance.invoke_command text }.not_to raise_error }
    
    it { instance.invoke_command(text).should =~ /i don't know how to/i }
  end # describe invoke_command
  
  context "defined actions" do
    let :command do :cry_havoc; end
    let :text    do "Cry havoc! And let slip the dogs of war."; end
    let :args    do %w(and let slip the dogs of war); end
    
    before :each do
      klass = Class.new described_class
      klass.define_action command do |session, args|
        args.join(" ")
      end # action cry_havoc
      
      Mithril::Mock.const_set :MockAbstractController, klass
    end # before each
    
    after :each do
      Mithril::Mock.send :remove_const, :MockAbstractController
    end # after each
    
    let :instance do Mithril::Mock::MockAbstractController.new request; end
    
    it { instance.should be_a Mithril::Mock::MockAbstractController }
    
    it { instance.should have_action command }
    
    describe :commands do
      it { expect(instance.commands).to include "cry havoc" }
    end # describe
    
    describe :can_invoke? do
      it { instance.can_invoke?(text).should be true }
    end # describe
    
    describe :invoke_command do
      it "invokes selected action" do
        instance.should_receive(:invoke_action).with(command, args).and_call_original
        instance.should_receive(:"action_#{command}").with(request.session, args).and_call_original
        instance.invoke_command text
      end # it invokes the selected action
      
      it { instance.invoke_command(text).should eq args.join(" ") }
      
      it { instance.invoke_command("not an action").should =~ /i don't know how to/i }
    end # describe invoke_command
    
    describe "inheriting defined actions" do
      before :each do
        klass = Class.new Mithril::Mock::MockAbstractController
        klass.send :define_method, :has_action? do |*args|
          # Mithril.logger.debug "#{class_name}.has_action?(), args = #{args.inspect}"
          super(*args)
        end # define method
        
        Mithril::Mock.const_set :MockAbstractControllerDescendant, klass
      end # before each
      
      after :each do
        Mithril::Mock.send :remove_const, :MockAbstractControllerDescendant
      end # after each
      
      let :instance do Mithril::Mock::MockAbstractControllerDescendant.new request; end
      
      it { instance.should be_a Mithril::Mock::MockAbstractControllerDescendant }
      it { instance.should be_a Mithril::Mock::MockAbstractController }
      
      it { instance.should respond_to :"action_#{command}"}
      it { instance.should have_action command }
    end # describe
  end # context defined actions
  
  describe "empty actions" do
    before :each do
      described_class.send :define_action, :"" do |session, arguments| arguments.join(' '); end
    end # before each
    
    let :text do "#{FactoryGirl.generate(:password).downcase} should be passed to an empty action"; end
    
    it { instance.should have_action :"" }
    
    describe :allow_empty_action? do
      it { instance.should respond_to :allow_empty_action? }
      it { expect { instance.allow_empty_action? }.not_to raise_error }
    end # describe
    
    context "disallow empty actions" do
      before :each do instance.stub :allow_empty_action? do false; end; end
      
      it { instance.can_invoke?(text).should be false }
      
      it { instance.invoke_command(text).should =~ /don't know how/ }
    end # context
    
    context "allow empty actions" do
      before :each do instance.stub :allow_empty_action? do true; end; end
      
      it "calls invoke_action with empty action" do
        instance.should_receive(:invoke_action).with(:"", text.split(' ')).and_call_original
        instance.invoke_command(text)
      end # it
      
      it { instance.can_invoke?(text).should be true }
      
      it { instance.invoke_command(text).should eq text }
    end # context
  end # describe empty actions
end # shared_examples
