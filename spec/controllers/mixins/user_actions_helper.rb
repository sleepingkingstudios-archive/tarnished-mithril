# spec/controllers/mixins/user_actions_helper.rb

require 'spec_helper'
require 'controllers/mixins/actions_base_helper'

require 'controllers/mixins/user_actions'

module Mithril
  module Mock; end
end # module

shared_examples_for Mithril::Controllers::Mixins::UserActions do
  it_behaves_like Mithril::Controllers::Mixins::ActionsBase
  
  context do
    before :each do
      if described_class.is_a? Class
        Mithril::Mock.const_set :MockUserActions, Class.new(described_class)
      elsif described_class.is_a? Module
        klass = Class.new
        klass.send :extend, Mithril::Controllers::Mixins::ActionMixin
        klass.send :mixin,  described_class
      
        Mithril::Mock.const_set :MockUserActions, klass
      end # if-elsif
    end # before each
  
    after :each do
      Mithril::Mock.send :remove_const, :MockUserActions
    end # after all
  
    let :mixin    do Mithril::Mock::MockUserActions; end
    let :instance do mixin.new; end
      
    it { instance.should respond_to :allow_registration? }
    it { expect { instance.allow_registration? }.not_to raise_error }
    
    describe "register action" do
      let :session   do {}; end
      let :arguments do []; end
      
      let :username do "tron"; end
      let :password do "i_fight_for_the_users"; end
      
      it { instance.should have_action :register }
      it { expect { instance.invoke_action(session, :register, arguments) }.not_to raise_error }
      it { instance.invoke_action(session, :register, arguments).should_not be_nil }
      
      context "registration closed" do
        before :each do
          instance.stub :allow_registration? do false; end
        end # before each
        
        it { instance.allow_registration?.should be false }
        
        it { instance.invoke_action(session, :register, arguments).should =~
            /registration is currently closed/i }
      end # context
      
      context "registration open" do
        before :each do
          instance.stub :allow_registration? do true; end
        end # before each
        
        it { instance.allow_registration?.should be true }
        
        describe "help" do
          let :arguments do %w(help); end
          
          it { instance.invoke_action(session, :register, arguments).should =~ /the register command/i }
        end # describe
        
        describe "not enough parameters" do
          let :arguments do %w(); end
          
          it { instance.invoke_action(session, :register, arguments).should =~
              /requires a username, password, and password confirmation/i }
        end # describe
        
        describe "password must match confirmation" do
          let :arguments do [username, password, ""]; end
          
          it { instance.invoke_action(session, :register, arguments).should =~
              /password and confirmation do not match/i }
        end # describe
        
        describe "with valid parameters" do
          let :arguments do [username, password, password]; end
          
          it { instance.invoke_action(session, :register, arguments).should =~
              /successfully created user "#{username}"/i }
        end # describe
      end # context
    end # describe
  end # context
end # shared examples
