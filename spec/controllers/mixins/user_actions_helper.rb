# spec/controllers/mixins/user_actions_helper.rb

require 'spec_helper'
require 'controllers/mixins/actions_base_helper'

require 'controllers/mixins/user_actions'

shared_examples_for Mithril::Controllers::Mixins::UserActions do
  it_behaves_like Mithril::Controllers::Mixins::ActionsBase
  
  it { instance.should respond_to :allow_registration? }
  it { expect { instance.allow_registration? }.not_to raise_error }
  
  describe "register action" do
    let :arguments do []; end
    
    let :username do FactoryGirl.generate :username; end
    let :password do FactoryGirl.generate :password; end
    
    it { instance.should have_action :register }
    it { expect { instance.invoke_action(:register, arguments) }.not_to raise_error }
    it { instance.invoke_action(:register, arguments).should_not be_nil }
    
    context "registration closed" do
      before :each do
        instance.stub :allow_registration? do false; end
      end # before each
      
      it { instance.allow_registration?.should be false }
      
      it { instance.invoke_action(:register, arguments).should =~
          /registration is currently closed/i }
    end # context
    
    context "registration open" do
      before :each do
        instance.stub :allow_registration? do true; end
      end # before each
      
      it { instance.allow_registration?.should be true }
      
      describe "help" do
        let :arguments do %w(help); end
        
        it { instance.invoke_action(:register, arguments).should =~ /the register command/i }
      end # describe
      
      describe "already logged in" do
        before :each do
          request.session = { :user_id => 0 }
          instance.stub :request do request; end
        end # before each
        
        it { instance.invoke_action(:register, arguments).should =~
          /already logged in/i }
      end # describe
      
      describe "not enough parameters" do
        let :arguments do %w(); end
        
        it { instance.invoke_action(:register, arguments).should =~
            /requires a username, password, and password confirmation/i }
      end # describe
      
      describe "password must match confirmation" do
        let :arguments do [username, password, ""]; end
        
        it { instance.invoke_action(:register, arguments).should =~
            /password and confirmation do not match/i }
      end # describe
      
      describe "username must be unique" do
        let :arguments do [username, password, password]; end
        
        before :each do FactoryGirl.create(:user, :username => username); end
        
        it { instance.invoke_action(:register, arguments).should =~
            /already a user named "#{username}"/i }
      end # describe
      
      describe "with valid parameters" do
        let :arguments do [username, password, password]; end
        
        it { instance.invoke_action(:register, arguments).should =~
            /now logged in as "#{username}"/i }
        
        context "registered" do
          before :each do
            request.session = Hash.new
            instance.stub :request do request; end
          end # before each
          
          before :each do instance.invoke_action(:register, arguments); end
          
          it { Mithril::Models::User.exists?(:username => username).should be true }
          
          it { request.session[:user_id].should be Mithril::Models::User.find_by_username(username).id }
        end # context
      end # describe
    end # context
  end # describe
  
  describe "login action" do
    let :arguments do []; end
    
    let :username do FactoryGirl.generate :username; end
    let :password do FactoryGirl.generate :password; end
    
    it { instance.should have_action :login }
    it { expect { instance.invoke_action(:login, arguments) }.not_to raise_error }
    it { instance.invoke_action(:login, arguments).should_not be_nil }
    
    describe "help" do
      let :arguments do %w(help); end
      
      it { instance.invoke_action(:login, arguments).should =~ /the login command/i }
    end # describe
    
    describe "not enough parameters" do
      let :arguments do %w(); end
      
      it { instance.invoke_action(:login, arguments).should =~
          /requires a username and password/i }
    end # describe
    
    describe "already logged in" do
      before :each do
        request.session = { :user_id => 0 }
        instance.stub :request do request; end
      end # before each
      
      it { instance.invoke_action(:login, arguments).should =~
        /already logged in/i }
    end # describe
    
    describe "invalid credentials" do
      let :arguments do [username, password]; end
      
      it { instance.invoke_action(:login, arguments).should =~
          /unable to authenticate user/i }
    end # describe
    
    context "registered users" do
      let! :user do
        FactoryGirl.create(:user, :username => username,
          :password => password, :password_confirmation => password)
      end # let
      
      describe "invalid credentials" do
        let :arguments do
          [FactoryGirl.generate(:username), FactoryGirl.generate(:password)]
        end # let

        it { instance.invoke_action(:login, arguments).should =~
            /unable to authenticate user/i }
      end # describe
      
      describe "valid credentials" do
        let :arguments do [username, password]; end
        
        before :each do
          request.session = Hash.new
          instance.stub :request do request; end
        end # before each
        
        it { instance.invoke_action(:login, arguments).should =~
            /now logged in as \"#{username}\"./i }
        
        context do
          before :each do instance.invoke_action(:login, arguments); end
          
          it { request.session[:user_id].should eq user.id }
        end # context
      end # describe
    end # context
  end # describe
end # shared examples
