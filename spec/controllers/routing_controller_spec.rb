# spec/controllers/routing_controller_spec.rb

require 'spec_helper'
require 'controllers/proxy_controller_helper'
require 'controllers/mixins/callback_helpers_helper'
require 'controllers/mixins/help_actions_helper'
require 'controllers/mixins/module_helpers_helper'
require 'controllers/mixins/user_helpers_helper'

require 'controllers/routing_controller'
require 'controllers/session_controller'
require 'controllers/user_controller'
require 'ingots/ingots'

describe Mithril::Controllers::RoutingController do
  let :request do FactoryGirl.build :request end
  let :described_class do Class.new super(); end
  let :instance do described_class.new request; end
  
  it_behaves_like Mithril::Controllers::ProxyController
  it_behaves_like Mithril::Controllers::Mixins::CallbackHelpers
  it_behaves_like Mithril::Controllers::Mixins::HelpActions
  it_behaves_like Mithril::Controllers::Mixins::ModuleHelpers
  it_behaves_like Mithril::Controllers::Mixins::UserHelpers
  
  before :each do
    klass = Class.new Mithril::Controllers::AbstractController
    Mithril::Mock.const_set :MockModuleController, klass
    Mithril::Ingots::Ingot.create :mock_module, klass
  end # before each
  
  after :each do
    Mithril::Mock.send :remove_const, :MockModuleController
  end # after each
  
  context "with no user selected" do
    let :arguments do []; end
    
    it { instance.proxy.should be_a Mithril::Controllers::UserController }
    
    it { instance.can_invoke?("login").should be true }
    it { instance.can_invoke?("register").should be true }
    it { instance.can_invoke?("logout").should be false }
    
    describe "registration" do
      before :each do
        Mithril::Controllers::UserController.send :define_method,
          :allow_registration? do true; end
      end # before :each
      
      let :username do FactoryGirl.generate :username; end
      let :password do FactoryGirl.generate :password; end
      
      let :user do
        Mithril::Models::User.find_by_username username
      end # let
      
      let :text do "register #{username} #{password} #{password}"; end
      
      before :each do instance.invoke_command(text); end
      
      it { user.should be_a Mithril::Models::User }
      
      it { request.session.should have_key :user_id }
      it { request.session[:user_id].should be user.id }
    end # describe
    
    describe "logging in" do
      let :username do FactoryGirl.generate :username; end
      let :password do FactoryGirl.generate :password; end
      let! :user do
        # Mithril::Models::User.create :username => username,
          # :password => password, :password_confirmation => password
        FactoryGirl.create :user, :username => username,
          :password => password, :password_confirmation => password
      end # let
      
      let :text do "login #{username} #{password}"; end
      
      before :each do instance.invoke_command(text); end
      
      it { user.authenticate(password).should_not eq false }
      
      it { request.session.should have_key :user_id }
      it { request.session[:user_id].should be user.id }
    end # describe
  end # context
  
  context "with a user selected" do
    let! :user do FactoryGirl.create :user; end
    let :arguments do []; end
    
    before :each do request.session[:user_id] = user.id; end
      
    it { instance.proxy.should be_a Mithril::Controllers::SessionController }
    
    it { instance.can_invoke?("login").should be false }
    it { instance.can_invoke?("register").should be false }
    it { instance.can_invoke?("logout").should be true }
    
    describe "logging out" do
      before :each do instance.invoke_command("logout"); end
      
      it { request.session[:user_id].should be nil }
    end # describe
    
    describe "selecting a module" do
      let :text do "module mock module"; end
      
      before :each do instance.invoke_command(text); end
      
      it { request.session[:module_key].should be :mock_module }
    end # describe
  end # context
  
  context "with a user and a module selected" do
    let! :user do FactoryGirl.create :user; end
    let :ingot do Mithril::Ingots::Ingot.find(:mock_module); end
    
    before :each do
      request.session[:user_id]    = user.id
      request.session[:module_key] = ingot.key
    end # before each
    
    it { instance.proxy.should be_a Mithril::Mock::MockModuleController }
    
    it { instance.can_invoke?("login").should be false }
    it { instance.can_invoke?("register").should be false }
    it { instance.can_invoke?("logout").should be false }
  end # context
  
  context "with a waiting callback" do
    before :each do
      klass = Class.new Mithril::Controllers::AbstractController
      klass.define_action :secret, :private => true do |session, arguments|
        arguments.join(' ')
      end # action
      Mithril::Controllers.const_set :MockPrivateController, klass
    end # before each
    
    after :each do
      Mithril::Controllers.send :remove_const, :MockPrivateController
    end # after each
    
    let :user do FactoryGirl.create :user; end
    let :callbacks do
      { :secret => { :controller => Mithril::Controllers::MockPrivateController, :action => :secret } }
    end # let
    let :arguments do %w(top secret); end
    let :text do "secret #{arguments.join(' ')}"; end
    
    before :each do
      request.session[:user_id] = user.id
      serialized = instance.serialize_callbacks(callbacks)
      instance.set_callbacks request.session, serialized
    end # before each
    
    context do
      let :private_controller do Mithril::Controllers::MockPrivateController.new(request); end
      
      it { private_controller.should have_action :secret, true }
    end # context
    
    it { instance.proxy.should be_a Mithril::Controllers::CallbackController }
    
    it { instance.can_invoke?("secret").should be true }
    it { instance.invoke_command(text).should eq arguments.join(' ') }
  end # context
end # describe
