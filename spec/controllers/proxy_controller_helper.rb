# spec/controllers/proxy_controller_helper.rb

require 'spec_helper'
require 'controllers/mixins/actions_base_helper'

require 'controllers/proxy_controller'

module Mithril
  module Mock; end
end # module

shared_examples_for Mithril::Controllers::ProxyController do
  it_behaves_like Mithril::Controllers::Mixins::ActionsBase
  
  before :each do
    proxy = Class.new described_class
    proxy.define_action :foo do |session, arguments|; "foo"; end
    Mithril::Mock.const_set :MockProxyController, proxy
    
    child = Class.new Mithril::Controllers::AbstractController
    child.define_action :bar do |session, arguments|; "bar"; end
    Mithril::Mock.const_set :MockChildController, child
  end # before each
  
  after :each do
    Mithril::Mock.send :remove_const, :MockProxyController
    Mithril::Mock.send :remove_const, :MockChildController
  end # after each
  
  let :proxy do Mithril::Mock::MockProxyController; end
  let :proxy_instance do proxy.new; end
  
  let :child do Mithril::Mock::MockChildController; end
  
  let :session   do {}; end
  let :arguments do []; end
  
  it { proxy_instance.should have_action :foo }
  it { child.new.should have_action :bar }
  it { proxy_instance.should_not have_action :bar }
  
  describe :allow_own_actions_while_proxied? do
    it { proxy_instance.should respond_to :allow_own_actions_while_proxied? }
    it { expect { proxy_instance.allow_own_actions_while_proxied? }.not_to raise_error }
  end # describe
  
  describe :proxy do
    it { proxy_instance.should respond_to :proxy }
    it { expect { proxy_instance.proxy }.not_to raise_error }
  end # describe proxy
  
  describe :own_actions do
    it { proxy_instance.should respond_to :own_actions }
    it { expect { proxy_instance.own_actions }.not_to raise_error }
    it { proxy_instance.own_actions.should have_key :foo }
    it { proxy_instance.own_actions.should_not have_key :bar }
  end # describe own actions
  
  describe :has_own_action? do
    it { proxy_instance.should respond_to :has_own_action? }
    it { expect { proxy_instance.has_own_action? }.to raise_error ArgumentError,
      /wrong number of arguments/i }
    it { expect { proxy_instance.has_own_action? :foo }.not_to raise_error }
    it { proxy_instance.should have_own_action :foo }
    it { proxy_instance.should_not have_own_action :bar }
  end # describe
  
  context "set proxy relationship" do
    let :child_instance do Mithril::Mock::MockChildController.new; end
    
    before :each do
      proxy_instance.stub :proxy do child_instance; end
    end # before each
    
    describe :proxy do
      it { proxy_instance.proxy.should be_a Mithril::Mock::MockChildController }
    end # describe  

    it { proxy_instance.should have_action :bar }

    it { proxy_instance.actions.should have_key :bar }
    
    it { expect { proxy_instance.invoke_action(session, :bar, arguments) }.not_to raise_error }
    
    describe :own_actions do
      it { proxy_instance.own_actions.should have_key :foo }
      it { proxy_instance.own_actions.should_not have_key :bar }
    end # describe own actions

    describe :has_own_action? do
      it { proxy_instance.should have_own_action :foo }
      it { proxy_instance.should_not have_own_action :bar }
    end # describe
    
    it "invokes the proxy's defined action" do
      child_instance.should_receive(:action_bar).with(session, arguments).and_call_original
      proxy_instance.invoke_action(session, :bar, arguments)
    end # it
    
    context "allow own actions while proxied" do
      before :each do
        Mithril::Mock::MockProxyController.send :define_method, :allow_own_actions_while_proxied? do
          true
        end # method
      end # before each
      
      it { proxy_instance.allow_own_actions_while_proxied?.should be true }
      
      it { proxy_instance.should have_action :foo }
      
      it { proxy_instance.actions.should have_key :foo }
      
      it { expect { proxy_instance.invoke_action(session, :foo, arguments) }.not_to raise_error }
      
      it "invokes the controllers's own action" do
        proxy_instance.should_receive(:action_foo).with(session, arguments).and_call_original
        proxy_instance.invoke_action(session, :foo, arguments)
      end # it
    end # context
    
    context "disallow own actions while proxied" do
      before :each do
        Mithril::Mock::MockProxyController.send :define_method, :allow_own_actions_while_proxied? do
          false
        end # method
      end # before each
      
      it { proxy_instance.allow_own_actions_while_proxied?.should be false }

      it { proxy_instance.should_not have_action :foo }

      it { proxy_instance.actions.should_not have_key :foo }

      it { expect { proxy_instance.invoke_action(session, :foo, arguments) }.not_to raise_error }

      it "does not invoke the controllers's own action" do
        proxy_instance.should_not_receive(:action_foo)
        proxy_instance.invoke_action(session, :foo, arguments)
      end # it
    end # context
  end # context
end # shared examples
