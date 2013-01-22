# spec/controllers/proxy_controller_helper.rb

require 'spec_helper'
require 'controllers/abstract_controller_helper'

require 'controllers/proxy_controller'

shared_examples_for Mithril::Controllers::ProxyController do
  it_behaves_like Mithril::Controllers::AbstractController
  
  let :proxy do described_class; end
  let :child do Class.new Mithril::Controllers::AbstractController; end
  let :proxy_instance do proxy.new request; end
  let :child_instance do child.new request; end
  
  before :each do
    proxy.define_action :foo do |session, arguments|; "foo"; end
    child.define_action :bar do |session, arguments|; "bar"; end
  end # before each
  
  let :session   do {}; end
  let :arguments do []; end
  
  it { proxy_instance.should have_action :foo }
  it { child_instance.should have_action :bar }
  it { proxy_instance.should_not have_action :bar }
  
  describe :allow_own_actions_while_proxied? do
    it { proxy_instance.should respond_to :allow_own_actions_while_proxied? }
    it { expect { proxy_instance.allow_own_actions_while_proxied? }.not_to raise_error }
  end # describe
  
  describe :proxy do
    it { proxy_instance.should respond_to :proxy }
    it { expect { proxy_instance.proxy }.not_to raise_error }
  end # describe proxy  
    
  describe :can_invoke? do
  it { proxy_instance.can_invoke?("foo").should be true }
  it { proxy_instance.can_invoke?("bar").should be false }
  end # describe
  
  describe :can_invoke_on_self? do
    it { proxy_instance.should respond_to :can_invoke_on_self? }
    it { expect { proxy_instance.can_invoke_on_self? }.to raise_error ArgumentError,
      /wrong number of arguments/i }
    it { expect { proxy_instance.can_invoke_on_self? "foo"}.not_to raise_error }
    it { proxy_instance.can_invoke_on_self?("foo").should be true }
    it { proxy_instance.can_invoke_on_self?("bar").should be false }
  end # describe
  
  context "set proxy relationship" do
    before :each do
      proxy_instance.stub :proxy do child_instance; end
    end # before each
    
    describe :proxy do
      it { proxy_instance.proxy.should be_a child }
    end # describe

    describe :can_invoke? do
      it { proxy_instance.can_invoke?("foo").should be true }
      it { proxy_instance.can_invoke?("bar").should be true }
    end # describe
    
    describe :can_invoke_on_self? do
      it { proxy_instance.can_invoke_on_self?("foo").should be true }
      it { proxy_instance.can_invoke_on_self?("bar").should be false }
    end # describe
    
    it { expect { proxy_instance.invoke_command("bar") }.not_to raise_error }
    
    it "invokes the proxy's defined action" do
      child_instance.should_receive(:action_bar).with(request.session, arguments).and_call_original
      proxy_instance.invoke_command "bar"
    end # it
    
    context "allow own actions while proxied" do
      before :each do
        proxy_instance.stub :allow_own_actions_while_proxied? do true; end
      end # before each
      
      it { proxy_instance.allow_own_actions_while_proxied?.should be true }
      
      it { proxy_instance.should have_action :foo }
      
      it { proxy_instance.actions.should have_key :foo }
      
      it { expect { proxy_instance.invoke_action(:foo, arguments) }.not_to raise_error }
      
      it "invokes the controllers's own action" do
        proxy_instance.should_receive(:action_foo).with(request.session, arguments).and_call_original
        proxy_instance.invoke_action(:foo, arguments)
      end # it
    end # context
    
    context "disallow own actions while proxied" do
      before :each do
        proxy_instance.stub :allow_own_actions_while_proxied? do false; end
      end # before each
      
      it { proxy_instance.allow_own_actions_while_proxied?.should be false }

      it "does not invoke the controllers's own action" do
        proxy_instance.should_not_receive(:action_foo)
        proxy_instance.invoke_command("foo")
      end # it
    end # context
  end # context
end # shared examples
