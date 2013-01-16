# spec/controllers/spooky_controller_spec.rb

require 'spec_helper'
require 'controllers/mixins/callback_helpers_helper'
require 'controllers/mixins/help_actions_helper'

require 'controllers/callback_controller'
require 'ingots/ingots'

describe Mithril::Controllers::CallbackController do
  it_behaves_like Mithril::Controllers::Mixins::CallbackHelpers
  it_behaves_like Mithril::Controllers::Mixins::HelpActions
  
  let :controller do described_class; end
  let :instance   do controller.new; end

  context "with a valid callback" do
    before :each do
      klass = Class.new(Mithril::Controllers::AbstractController)
      klass.send :define_action, :do_foo do |session, arguments|; arguments.join(' '); end
      Mithril::Controllers.const_set :FooController, klass
      
      klass = Class.new(Mithril::Controllers::AbstractController)
      klass.send :define_action, :do_bar do |session, arguments|; arguments.join(' '); end
      Mithril::Controllers.const_set :BarController, klass
    end # before each
    
    after :each do
      Mithril::Controllers.send :remove_const, :FooController
      Mithril::Controllers.send :remove_const, :BarController
    end # after each
    
    let :session   do {}; end
    let :callbacks do { "foo" => "FooController,do_foo", "bar" => "BarController,do_bar" }; end
    
    before :each do instance.set_callbacks(session, callbacks); end
    
    context do
      before :each do
        instance.instance_variable_set :@callbacks, instance.deserialize_callbacks(callbacks)
      end # before each
      
      after :each do
        instance.instance_variable_set :@callbacks, nil
      end # after each
      
      describe :actions do
        it { instance.actions.should have_key :foo }
        it { instance.actions.should have_key :bar }
      end # describe
      
      describe :has_action? do
        it { instance.should have_action :foo }
        it { instance.should have_action :bar }
      end # describe
    end # context
    
    describe :invoke_action do
      let :arguments do %w(wibble wobble); end
      
      it { expect { instance.invoke_action(session, :foo, arguments) }.not_to raise_error }
      it { instance.invoke_action(session, :foo, arguments).should eq "wibble wobble" }
      
      context do
        before :each do instance.invoke_action(session, :foo, arguments); end
        
        it { session.should eq Hash.new }
      end # context
      
      it { expect { instance.invoke_action(session, :bar, arguments) }.not_to raise_error }
      it { instance.invoke_action(session, :bar, arguments).should eq "wibble wobble" }
      
      context do
        before :each do instance.invoke_action(session, :bar, arguments); end
        
        it { session.should eq Hash.new }
      end # context
    end # describe
    
    describe :invoke_command do
      context do
        let :text do "foo wibble wobble"; end
        
        it { expect { instance.invoke_command(session, text) }.not_to raise_error }
        it { instance.invoke_command(session, text).should eq "wibble wobble" }
        
        context do
          before :each do instance.invoke_command(session, text); end

          it { session.should eq Hash.new }
        end # context
      end # context
      
      context do
        let :text do "bar wibble wobble"; end

        it { expect { instance.invoke_command(session, text) }.not_to raise_error }
        it { instance.invoke_command(session, text).should eq "wibble wobble" }

        context do
          before :each do instance.invoke_command(session, text); end

          it { session.should eq Hash.new }
        end # context
      end # context
    end # describe invoke_command
  end # describe
end # describe
