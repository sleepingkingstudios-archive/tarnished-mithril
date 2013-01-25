# spec/controllers/mixins/help_actions_helper.rb

require 'spec_helper'
require 'controllers/mixins/actions_base_helper'

require 'controllers/mixins/help_actions'

shared_examples_for Mithril::Controllers::Mixins::HelpActions do
  it_behaves_like Mithril::Controllers::Mixins::ActionsBase
  
  let :request  do FactoryGirl.build :request; end
  
  describe :help_string do
    it { expect(instance).to respond_to :help_string }
    it { expect { instance.help_string }.not_to raise_error }
    it { expect(instance.help_string).to be_a String }
  end # describe help_string
  
  describe "help" do
    let :arguments do []; end
    
    it { expect(instance).to have_action :help }
    it { expect { instance.invoke_action(:help, arguments) }.not_to raise_error }
    it { expect(instance.invoke_action :help, arguments).to be_a String }
    
    it { expect(instance.invoke_action :help, arguments).
      to match /following commands are available/i }
    it { expect(instance.invoke_action :help, arguments).to match /help/i }
    
    describe "help" do
      let :arguments do %w(help); end
      
      it { expect(instance.invoke_action :help, arguments)
        .to match /the help command/i }
    end # describe help
    
    context "with a help string defined" do
      before :each do
        instance.stub :help_string do
          "You put your left foot in, you take your left foot out."
        end # stub
      end # before each
      
      it { expect(instance.invoke_action :help, arguments)
        .to match /put your left foot in/i }
      
      it { expect(instance.invoke_action :help, arguments)
        .to match /following commands are available/i }
    end # context
    
    context "with additional actions defined" do
      def self.action_keys
        [:foo, :bar, :baz]
      end # class method action_keys
      
      let :action_keys do self.class.action_keys; end
      
      before :each do
        action_keys.each do |key|
          described_class.send :define_action, key do |session, arguments|; end
        end # each
      end # before each
      
      action_keys.each do |command|
        context do
          it { expect(instance).to have_action command }
          
          it { expect(instance.invoke_action :help, arguments)
            .to match /#{command}/i }
          
          it "invokes the action with args = help" do
            instance.should_receive(:"action_#{command}").with({}, %w(help))
            instance.invoke_action(:help, [command.to_s])
          end # it
        end # context
      end # each
    end # context
    
    context "with additional commands" do
      def self.command_keys
        %w(wibble wobble)
      end # class method command_keys
      
      let :command_keys do self.class.command_keys; end
      
      before :each do
        instance.stub :commands do command_keys; end
        instance.stub :has_command? do |command| command_keys.include? command; end
      end # before each
      
      command_keys.each do |command|
        context do
          it { expect(instance).to have_command command }
          
          it { expect(instance.invoke_action :help, arguments)
            .to match /#{command}/i }
            
          it "invokes the command with args = help" do
            instance.should_receive(:invoke_command).with("#{command} help")
            instance.invoke_action(:help, [command])
          end # it
        end # anonymous context
      end # each
    end # context
  end # describe
end # shared examples
