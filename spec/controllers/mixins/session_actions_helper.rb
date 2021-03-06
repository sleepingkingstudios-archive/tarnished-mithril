# spec/controllers/mixins/session_actions_helper.rb

require 'spec_helper'
require 'controllers/mixins/actions_base_helper'
require 'controllers/mixins/user_helpers_helper'

require 'controllers/abstract_controller'
require 'controllers/mixins/session_actions'
require 'ingots/ingots'

shared_examples_for Mithril::Controllers::Mixins::SessionActions do
  it_behaves_like Mithril::Controllers::Mixins::ActionsBase
  it_behaves_like Mithril::Controllers::Mixins::UserHelpers
  
  describe "logout action" do
    let :arguments do []; end
    
    it { instance.should have_action :logout }
    it { expect { instance.invoke_action(:logout, arguments) }.not_to raise_error }
    it { instance.invoke_action(:logout, arguments).should be_a String }
    
    describe "help" do
      let :arguments do %w(help); end
      
      it { instance.invoke_action(:logout, arguments).should =~ /the logout action/i }
    end # describe
    
    describe "with no user logged in" do
      it { instance.invoke_action(:logout, arguments).should =~
        /not currently logged in/i }
    end # describe
    
    describe "with a user defined" do
      let :user do FactoryGirl.create :user; end
      
      before :each do
        request.session = { :user_id => user.id, :module_key => :mock_module }
        instance.stub :request do request; end
      end # before each
      
      it { instance.invoke_action(:logout, arguments).should =~
        /successfully logged out/i }
      
      context do
        before :each do instance.invoke_action(:logout, arguments); end
        
        it { request.session[:module_key].should be nil }
        it { request.session[:user_id].should be nil }
      end # context
    end # describe
  end # describe
  
  describe "module action" do
    let :session   do {}; end
    let :arguments do []; end
    
    it { instance.should have_action :module }
    it { expect { instance.invoke_action(:module, arguments) }.not_to raise_error }
    it { instance.invoke_action(:module, arguments).should be_a String }
    
    describe "help" do
      let :arguments do %w(help); end
      
      it { instance.invoke_action(:module, arguments).should =~ /the module command/i }
    end # describe
    
    describe "list" do
      let :arguments do %w(list); end
      
      before :each do
        Mithril::Ingots::Ingot.instance_variable_set :@modules, nil
      end # before each
      
      it { instance.invoke_action(:module, arguments).should =~ /no modules available/i }
    end # describe
    
    describe "with no arguments" do
      let :arguments do []; end
      
      it { instance.invoke_action(:module, arguments).should =~
        /must enter a module name/i }
    end # describe
    
    context "with modules defined" do
      def self.module_keys
        [ :disc_wars, :light_cycles, :space_paranoids ]
      end # self.module_keys
      
      let :module_keys do self.class.module_keys; end
      
      before :each do
        self.class.module_keys.each do |key|
          Mithril::Ingots::Ingot.create key, Mithril::Controllers::AbstractController
        end # each
      end # before each

      after :each do
        Mithril::Ingots::Ingot.instance_variable_set :@modules, nil
      end # after each
      
      describe "list" do
        let :arguments do %w(list); end
        
        module_keys.each do |key|
          context do
            let :ingot do Mithril::Ingots::Ingot.find(key); end
          
            it { instance.invoke_action(:module, arguments).should =~ /#{ingot.name}/i }
          end # context
        end # each
      end # describe
      
      describe "with a module already selected" do
        before :each do
          request.session = { :module_key => module_keys.first }
          instance.stub :request do request; end
        end # before each
        
        let :arguments do [module_keys.last.to_s]; end
        it { instance.invoke_action(:module, arguments).should =~
          /already a module selected/i }
      end # describe
      
      describe "invalid module name" do
        let :session do {}; end
        let :arguments do %w(pong); end
        
        it { instance.invoke_action(:module, arguments).should =~
          /unable to load module "pong"/i }
      end # describe
      
      describe "selecting a module" do
        before :each do
          request.session = Hash.new
          instance.stub :request do request; end
        end # before each
        
        module_keys.each do |key|
          context do
            let :ingot do Mithril::Ingots::Ingot.find(key); end
            let :arguments do [ingot.name]; end
            
            it { instance.invoke_action(:module, arguments).should =~
              /selected the #{ingot.name} module/i }
              
            context do
              before :each do instance.invoke_action(:module, arguments); end
              
              it { request.session[:module_key].should be ingot.key }
            end # context
          end # context
        end # each
      end # describe
    end # context
  end # describe module action
end # shared examples
