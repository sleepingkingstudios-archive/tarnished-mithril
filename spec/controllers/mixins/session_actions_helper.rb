# spec/controllers/mixins/session_actions_helper.rb

require 'spec_helper'
require 'controllers/mixins/actions_base_helper'

require 'controllers/mixins/session_actions'

shared_examples_for Mithril::Controllers::Mixins::SessionActions do
  it_behaves_like Mithril::Controllers::Mixins::ActionsBase
  
  before :each do
    if described_class.is_a? Class
      Mithril::Mock.const_set :MockSessionActions, Class.new(described_class)
    elsif described_class.is_a? Module
      klass = Class.new
      klass.send :extend, Mithril::Controllers::Mixins::ActionMixin
      klass.send :mixin,  described_class
    
      Mithril::Mock.const_set :MockSessionActions, klass
    end # if-elsif
  end # before each

  after :each do
    Mithril::Mock.send :remove_const, :MockSessionActions
  end # after all

  let :mixin    do Mithril::Mock::MockSessionActions; end
  let :instance do mixin.new; end
  
  describe "current user" do
    let :session do {}; end
    
    it { instance.should respond_to :current_user }
    it { expect { instance.current_user(session) }.not_to raise_error }
    it { instance.current_user(session).should be nil }
    
    context "with a user selected" do
      let :user do FactoryGirl.create :user; end
      let :session do { :user_id => user.id }; end
      
      it { instance.current_user(session).should eq user }
    end # context
  end # describe current user
  
  describe "logout action" do
    let :session   do {}; end
    let :arguments do []; end
    
    it { instance.should have_action :logout }
    it { expect { instance.invoke_action(session, :logout, arguments) }.not_to raise_error }
    it { instance.invoke_action(session, :logout, arguments).should be_a String }
    
    describe "help" do
      let :arguments do %w(help); end
      
      it { instance.invoke_action(session, :logout, arguments).should =~ /the logout action/i }
    end # describe
    
    describe "with no user logged in" do
      it { instance.invoke_action(session, :logout, arguments).should =~
        /not currently logged in/i }
    end # describe
    
    describe "with a user defined" do
      let :user do FactoryGirl.create :user; end
      let :session do { :user_id => user.id }; end
      
      it { instance.invoke_action(session, :logout, arguments).should =~
        /successfully logged out/i }
      
      context do
        before :each do instance.invoke_action(session, :logout, arguments); end
        
        it { session[:user_id].should be nil }
      end # context
    end # describe
  end # describe
end # shared examples
