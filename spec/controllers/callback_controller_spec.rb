# spec/controllers/spooky_controller_spec.rb

require 'spec_helper'
require 'controllers/abstract_controller_helper'
require 'controllers/mixins/callback_helpers_helper'
require 'controllers/mixins/help_actions_helper'

require 'controllers/callback_controller'
require 'ingots/ingots'

describe Mithril::Controllers::CallbackController do
  let :request do FactoryGirl.build :request end
  let :described_class do Class.new super(); end
  let :instance do described_class.new request; end
  
  it_behaves_like Mithril::Controllers::AbstractController
  it_behaves_like Mithril::Controllers::Mixins::CallbackHelpers
  it_behaves_like Mithril::Controllers::Mixins::HelpActions
  
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
    
    let :callbacks do { "foo" => "FooController,do_foo", "bar" => "BarController,do_bar" }; end
    
    before :each do instance.set_callbacks(request.session, callbacks); end
    
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
      
      it { expect { instance.invoke_action(:foo, arguments) }.not_to raise_error }
      it { instance.invoke_action(:foo, arguments).should eq "wibble wobble" }
      
      context do
        before :each do instance.invoke_action(:foo, arguments); end
        
        it { request.session.should eq Hash.new }
      end # context
      
      it { expect { instance.invoke_action(:bar, arguments) }.not_to raise_error }
      it { instance.invoke_action(:bar, arguments).should eq "wibble wobble" }
      
      context do
        before :each do instance.invoke_action(:bar, arguments); end
        
        it { request.session.should eq Hash.new }
      end # context
    end # describe
    
    describe :invoke_command do
      context do
        let :text do "foo wibble wobble"; end
        
        it { expect { instance.invoke_command(text) }.not_to raise_error }
        it { instance.invoke_command(text).should eq "wibble wobble" }
        
        context do
          before :each do instance.invoke_command(text); end

          it { request.session.should eq Hash.new }
        end # context
      end # context
      
      context do
        let :text do "bar wibble wobble"; end

        it { expect { instance.invoke_command(text) }.not_to raise_error }
        it { instance.invoke_command(text).should eq "wibble wobble" }

        context do
          before :each do instance.invoke_command(text); end

          it { request.session.should eq Hash.new }
        end # context
      end # context
    end # describe invoke_command
  end # describe
end # describe
