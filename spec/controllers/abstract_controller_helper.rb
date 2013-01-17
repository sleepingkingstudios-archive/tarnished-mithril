# spec/controllers/abstract_controller_helper.rb

require 'spec_helper'
require 'controllers/mixins/actions_base_helper'

require 'controllers/abstract_controller'
require 'request'

shared_examples_for Mithril::Controllers::AbstractController do
  it_behaves_like Mithril::Controllers::Mixins::ActionsBase, [Mithril::Request.new]
  
  before :each do
    klass = Class.new described_class
    Mithril::Mock.const_set :MockController, klass
  end # before each
  
  after :each do
    Mithril::Mock.send :remove_const, :MockController
  end # after each
  
  let :request    do
    request = Mithril::Request.new
    request.session = {}
    request
  end # let
  let :controller do Mithril::Mock::MockController; end
  let :instance   do controller.new request; end
  
  describe :constructor do
    it { expect { controller.new }.to raise_error ArgumentError,
      /wrong number of arguments/i }
    it { expect { controller.new nil }.to raise_error ArgumentError,
      /expected to be Mithril::Request/i }
    it { expect { controller.new request }.not_to raise_error }
  end # describe constructor
  
  # Probably shouldn't have this here, since it's not strictly a public api,
  # but better to find text processing errors here than in the wild.
  describe :preprocess_input do
    let :input do "ooooooooooooooo"; end
    
    it { instance.should respond_to :preprocess_input }
    
    it { expect { instance.preprocess_input }.to raise_error ArgumentError,
      /wrong number of arguments/i }
    
    it { expect { instance.preprocess_input input }.not_to raise_error }
    
    it "strips leading and trailing whitespace" do
      instance.preprocess_input("\n\t#{input}    \r").should eq input
    end # it
    
    it "downcases the input" do
      instance.preprocess_input(input.split("").each_with_index.map { |char, index|
        1 == ((index / 3) & 1) ? char.upcase : char
      }.join("")).should eq input 
    end # it
    
    it "normalises internal whitespace" do
      instance.preprocess_input("#{input}  \r#{input}\n\t#{input}").
        should eq "#{input} #{input} #{input}"
    end # it
    
    context do
      let :input do "\"Bravely?\" Ha! Lily-livered; poultroon!" +
        " Coward's trousers, anointed. (person: scared [afraid])"; end
      
      it "strips punctuation" do
        instance.preprocess_input(input).
          should eq "bravely ha lily livered poultroon cowards trousers anointed person scared afraid"
      end # it
    end # context
  end # describe preprocess input
  
  # Wordify. Words fail me, or perhaps I have failed them.
  describe :wordify do
    let :words do %w(second star to the right and straight on till morning); end
    
    it { instance.should respond_to :wordify }
    
    it { expect { instance.wordify }.to raise_error ArgumentError,
      /wrong number of arguments/i }
    
    it { expect { instance.wordify words.join(" ") }.not_to raise_error }
    
    it { instance.wordify(words.join(" ")).should eq words }
    it { instance.wordify(words.join("\n")).should eq words }
  end # describe wordify
  
  describe :parse_command do
    let :input do "Do Re Mi"; end
    
    it { instance.should respond_to :parse_command }
    
    it { expect { instance.parse_command }.to raise_error ArgumentError,
      /wrong number of arguments/i }
    
    it { expect { instance.parse_command input }.not_to raise_error }
    
    it "preprocesses the text input" do
      instance.should_receive(:preprocess_input).with(input).and_call_original
      instance.parse_command input
    end # it
    
    context do
      before :each do
        instance.stub :has_action? do |key|
          [:do, :do_while, :do_not, :doo_wop].include? key
        end # stub
      end # before :each
      
      it do
        command, arguments = instance.parse_command("Don't stop believing!")
        
        command.should be nil
      end # it
      
      it do
        command, arguments = instance.parse_command("Do you hear the people sing?")
        
        command.should be :do
        arguments.should eq %w(you hear the people sing)
      end # it
      
      it do
        command, arguments = instance.parse_command("Do, or do not. There is no try.")
        
        command.should   be :do
        arguments.should eq %w(or do not there is no try)
      end # it
      
      it do
        command, arguments = instance.parse_command("Do while is a useful construct.")
        
        command.should   be :do_while
        arguments.should eq %w(is a useful construct)
      end # it
    end # anonymous context
  end # describe parse_command
  
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
    
    describe :invoke_command do
      it "preprocesses text" do
        instance.should_receive(:preprocess_input).with(text).and_call_original
        instance.invoke_command text
      end # it
      
      it "invokes selected action" do
        Mithril.logger.debug "request = #{request.inspect}, session = #{request.session}"
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
    
    let :text do "foo bar baz"; end
    
    it { instance.should have_action :"" }
    
    describe :allow_empty_action? do
      it { instance.should respond_to :allow_empty_action? }
      it { expect { instance.allow_empty_action? }.not_to raise_error }
    end # describe
    
    context "disallow empty actions" do
      before :each do instance.stub :allow_empty_action? do false; end; end
      
      it { instance.invoke_command(text).should =~ /don't know how/ }
    end # context
    
    context "allow empty actions" do
      before :each do instance.stub :allow_empty_action? do true; end; end
      
      it "calls invoke_action with empty action" do
        instance.should_receive(:invoke_action).with(:"", %w(foo bar baz)).and_call_original
        instance.invoke_command(text)
      end # it
      
      it { instance.invoke_command(text).should eq text }
    end # context
  end # describe empty actions
end # shared_examples
