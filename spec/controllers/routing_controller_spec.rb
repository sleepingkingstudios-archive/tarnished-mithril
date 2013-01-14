# spec/controllers/routing_controller_spec.rb

require 'spec_helper'
require 'controllers/proxy_controller_helper'
require 'controllers/mixins/help_actions_helper'
require 'controllers/mixins/user_helpers_helper'

require 'controllers/routing_controller'
require 'controllers/session_controller'
require 'controllers/user_controller'

describe Mithril::Controllers::RoutingController do
  it_behaves_like Mithril::Controllers::ProxyController
  it_behaves_like Mithril::Controllers::Mixins::HelpActions
  it_behaves_like Mithril::Controllers::Mixins::UserHelpers
  
  before :each do
    klass = Class.new described_class
    Mithril::Mock.const_set :MockRoutingController, klass
  end # before each
  
  after :each do
    Mithril::Mock.send :remove_const, :MockRoutingController
  end # after each
  
  let :controller do Mithril::Mock::MockRoutingController; end
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
  end # context
end # describe
