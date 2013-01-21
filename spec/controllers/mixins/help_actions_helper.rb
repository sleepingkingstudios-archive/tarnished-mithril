# spec/controllers/mixins/help_actions_helper.rb

require 'spec_helper'
require 'controllers/mixins/actions_base_helper'

require 'controllers/mixins/help_actions'

shared_examples_for Mithril::Controllers::Mixins::HelpActions do
  it_behaves_like Mithril::Controllers::Mixins::ActionsBase
  
  let :request  do FactoryGirl.build :request; end
  
  it { instance.should respond_to :help_string }
  it { expect { instance.help_string }.not_to raise_error }
  it { instance.help_string.should be_a String }
  
  describe "help" do
    let :arguments do []; end
    
    it { instance.should have_action :help }
    it { expect { instance.invoke_action(:help, arguments) }.not_to raise_error }
    it { instance.invoke_action(:help, arguments).should be_a String }
    
    it { instance.invoke_action(:help, arguments).should =~
      /following commands are available/i }
    it { instance.invoke_action(:help, arguments).should =~ /help/i }
    
    describe "help" do
      let :arguments do %w(help); end
      
      it { instance.invoke_action(:help, arguments).should =~ /the help command/i }
    end # describe help
    
    context "with a help string defined" do
      before :each do
        instance.stub :help_string do "You put your left foot in, you take your left foot out."; end
      end # before each
      
      it { instance.invoke_action(:help, arguments).should =~
        /put your left foot in/i }
      
      it { instance.invoke_action(:help, arguments).should =~
        /following commands are available/i }
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
          let :key do key; end
          
          it { instance.should have_action command }
          
          it { instance.invoke_action(:help, arguments).should =~ /#{command}/i }
          
          it "invokes the action with args = help" do
            instance.should_receive(:"action_#{command}").with({}, %w(help))
            instance.invoke_action(:help, [command.to_s])
          end # it
        end # context
      end # each
    end # context
  end # describe
end # shared examples
