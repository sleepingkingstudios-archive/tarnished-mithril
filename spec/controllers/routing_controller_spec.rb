# spec/controllers/routing_controller_spec.rb

require 'spec_helper'
require 'controllers/proxy_controller_helper'
require 'controllers/mixins/help_actions_helper'
require 'controllers/mixins/module_helpers_helper'
require 'controllers/mixins/user_helpers_helper'

require 'controllers/routing_controller'
require 'controllers/session_controller'
require 'controllers/user_controller'
require 'ingots/ingots'

describe Mithril::Controllers::RoutingController do
  it_behaves_like Mithril::Controllers::ProxyController
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
  
  let :controller do described_class; end
  let :instance   do controller.new; end
  
  context "with no user selected" do
    let :session   do {}; end
    let :arguments do []; end
    
    before :each do instance.instance_variable_set :@session, session; end
    after  :each do instance.instance_variable_set :@session, nil; end
    
    context do
      before :each do instance.instance_variable_set :@session, session; end
      after  :each do instance.instance_variable_set :@session, nil; end
      
      it { instance.proxy.should be_a Mithril::Controllers::UserController }
      
      it { instance.should have_action :login }
      it { instance.should have_action :register }
      it { instance.should_not have_action :logout }
    end # context
    
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
      
      let :arguments do [username, password, password]; end
      
      before :each do instance.invoke_action(session, :register, arguments); end
      
      it { user.should be_a Mithril::Models::User }
      
      it { session.should have_key :user_id }
      it { session[:user_id].should be user.id }
    end # describe
    
    describe "logging in" do
      let :username do FactoryGirl.generate :username; end
      let :password do FactoryGirl.generate :password; end
      let! :user do
        FactoryGirl.create :user, :username => username,
          :password => password, :password_confirmation => password
      end # let
      
      let :arguments do [username, password]; end
      
      before :each do instance.invoke_action(session, :login, arguments); end
      
      it { session.should have_key :user_id }
      it { session[:user_id].should be user.id }
    end # describe
  end # context
  
  context "with a user selected" do
    let! :user do FactoryGirl.create :user; end
    let :session do { :user_id => user.id }; end
    let :arguments do []; end
    
    context do
      before :each do instance.instance_variable_set :@session, session; end
      after  :each do instance.instance_variable_set :@session, nil; end
      
      it { instance.proxy.should be_a Mithril::Controllers::SessionController }
      
      it { instance.should_not have_action :login }
      it { instance.should_not have_action :register }
      it { instance.should have_action :logout }
    end # context
    
    describe "logging out" do
      before :each do instance.invoke_action(session, :logout, arguments); end
      
      it { session[:user_id].should be nil }
    end # describe
    
    describe "selecting a module" do
      let :arguments do %w(mock module); end
      
      before :each do instance.invoke_action(session, :module, arguments); end
      
      it { session[:module_key].should be :mock_module }
    end # describe
  end # context
  
  context "with a user and a module selected" do
    let! :user do FactoryGirl.create :user; end
    let :ingot do Mithril::Ingots::Ingot.find(:mock_module); end
    let :session do { :user_id => user.id, :module_key => ingot.key }; end
    
    context do
      before :each do instance.instance_variable_set :@session, session; end
      after  :each do instance.instance_variable_set :@session, nil; end
    
      it { instance.proxy.should be_a Mithril::Mock::MockModuleController }
    
      it { instance.should_not have_action :login }
      it { instance.should_not have_action :register }
      it { instance.should_not have_action :logout }
    end # context
    
    describe "guarding session user_id" do
      before :each do
        klass = Class.new(Mithril::Controllers::AbstractController)
        klass.define_action :set_user_id do |session, arguments|
          arguments.empty? ?
            session[:user_id] = nil :
            session[:user_id] = arguments.first.to_i
        end # do
        instance.stub :proxy do klass.new; end
      end # before each
      
      it { instance.proxy.should have_action :set_user_id }
      
      describe "setting user_id from nil" do
        let :session do {}; end
        let :text do "set user id 15151"; end
        
        before :each do instance.invoke_command(session, text); end
        
        it { session[:user_id].should be 15151 }
      end # describe
      
      describe "setting user_id to nil" do
        let :session do { :user_id => 42 }; end
        let :text do "set user id"; end
        
        before :each do instance.invoke_command(session, text); end
        
        it { session[:user_id].should be nil }
      end # describe
      
      describe "setting user_id to a different number" do
        let :session do { :user_id => 42 }; end
        let :text do "set user id 15151"; end
        
        before :each do instance.invoke_command(session, text); end
        
        it { session[:user_id].should be 42 }
      end # describe
    end # describe
    
    describe "guarding session module_key" do
      before :each do
        klass = Class.new(Mithril::Controllers::AbstractController)
        klass.define_action :set_module_key do |session, arguments|
          arguments.empty? ?
            session[:module_key] = nil :
            session[:module_key] = arguments.join('_').intern
        end # do
        instance.stub :proxy do klass.new; end
      end # before each
      
      it { instance.proxy.should have_action :set_module_key }
      
      describe "setting module_key from nil" do
        let :session do {}; end
        let :text do "set module key my module"; end
        
        before :each do instance.invoke_command(session, text); end
        
        it { session[:module_key].should be :my_module }
      end # describe
      
      describe "setting module_key to nil" do
        let :session do { :module_key => :my_module }; end
        let :text do "set module key"; end
        
        before :each do instance.invoke_command(session, text); end
        
        it { session[:module_key].should be nil }
      end # describe
      
      describe "setting user_id to a different number" do
        let :session do { :module_key => :my_module }; end
        let :text do "set module key malicious module"; end
        
        before :each do instance.invoke_command(session, text); end
        
        it { session[:module_key].should be :my_module }
      end # describe
    end # describe
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
    let :session do { :user_id => user.id }; end
    
    # before :each do
    #   callback_controller = Mithril::Controllers::CallbackController.new
    #   callbacks = callback_controller.serialize_callbacks callbacks
    #   callback_controller = 
    # end # before each
    
    it { Mithril::Controllers::MockPrivateController.new.should have_action :secret, true }
  end # context
end # describe
