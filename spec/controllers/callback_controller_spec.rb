# spec/controllers/spooky_controller_spec.rb

require 'spec_helper'
require 'controllers/mixins/help_actions_helper'

require 'controllers/callback_controller'
require 'ingots/ingots'

describe Mithril::Controllers::CallbackController do
  it_behaves_like Mithril::Controllers::Mixins::HelpActions
  
  let :controller do described_class; end
  let :instance   do controller.new; end
  
  describe :resolve_controller do
    it { instance.should respond_to :resolve_controller }
    it { expect { instance.resolve_controller }.to raise_error ArgumentError,
      /wrong number of arguments/i }
    it { expect { instance.resolve_controller "" }.not_to raise_error }
    it { instance.resolve_controller("").should be_nil }
    
    describe "attempting to resolve a non-controller constant" do
      let :path do "MaliciousConstant"; end
      
      before :each do Mithril::Controllers.const_set path.intern, Kernel; end
      
      after :each do Mithril::Controllers.send :remove_const, path.intern; end
      
      it { instance.resolve_controller(path).should be nil }
    end # describe
    
    describe "resolving a core controller" do
      let :path do "AbstractController"; end
      
      it { instance.resolve_controller(path).should be Mithril::Controllers::AbstractController }
    end # describe
    
    describe "resolving a controller in an interactive module" do
      before :each do
        Mithril::Ingots.const_set :MockModule, Module.new
        Mithril::Ingots::MockModule.const_set :Controllers, Module.new
        Mithril::Ingots::MockModule::Controllers.const_set :MockModuleController,
          Class.new(Mithril::Controllers::AbstractController)
      end # before each
      
      after :each do
        Mithril::Ingots::MockModule::Controllers.send :remove_const, :MockModuleController
        Mithril::Ingots::MockModule.send :remove_const, :Controllers
        Mithril::Ingots.send :remove_const, :MockModule
      end # after each
      
      let :path do "MockModule:MockModuleController"; end
      let :module_controller do Mithril::Ingots::MockModule::Controllers::MockModuleController; end
      
      it { instance.resolve_controller(path).should be module_controller }
    end # describe
  end # describe resolve_controller
  
  describe :serialize_callbacks do
    let :session   do {}; end
    let :callbacks do
      { "action" => { :controller => Mithril::Controllers::AbstractController, :action => "" }}
    end # let
    
    it { instance.should respond_to :serialize_callbacks }
    it { expect { instance.serialize_callbacks }.to raise_error ArgumentError,
      /wrong number of arguments/i }
    it { expect { instance.serialize_callbacks(session) }.to raise_error ArgumentError,
      /wrong number of arguments/i }
    it { expect { instance.serialize_callbacks(session, callbacks) }.not_to raise_error }
    it { instance.serialize_callbacks(session, callbacks).should_not be_nil }
    
    describe "with an empty callbacks hash" do
      let :callbacks do {}; end
      
      it { expect { instance.serialize_callbacks(session, callbacks) }.
        to raise_error Mithril::Controllers::CallbackControllerError,
        /empty callbacks hash/i }
    end # describe
    
    describe "with a nil controller" do
      let :callback_key do "foo"; end
      let :callbacks do { callback_key => { :action => "" } }; end
      
      it { expect { instance.serialize_callbacks(session, callbacks) }.
        to raise_error Mithril::Controllers::CallbackControllerError,
        /malformed callbacks hash/i }
      
      it "describes the error" do
        begin
          instance.serialize_callbacks(session, callbacks)
        rescue Mithril::Controllers::CallbackControllerError => exception
          exception.errors[callback_key].should include "expected controller not to be nil"
        end # begin-rescue
      end # it
    end # describe
    
    describe "with a non-controller controller" do
      let :path do "MaliciousConstant"; end
      
      before :each do Mithril::Controllers.const_set path.intern, Kernel; end
      
      after :each do Mithril::Controllers.send :remove_const, path.intern; end
      
      let :callback_key do "foo"; end
      let :callbacks do { callback_key => { :action => "", :controller => Mithril::Controllers::MaliciousConstant } }; end
      
      it { expect { instance.serialize_callbacks(session, callbacks) }.
        to raise_error Mithril::Controllers::CallbackControllerError,
        /malformed callbacks hash/i }
      
      it "describes the error" do
        begin
          instance.serialize_callbacks(session, callbacks)
        rescue Mithril::Controllers::CallbackControllerError => exception
          exception.errors[callback_key].should include "expected controller to extend AbstractController"
        end # begin-rescue
      end # it
    end # describe
    
    describe "with a nil action" do
      let :callback_key do "foo"; end
      let :callbacks do { callback_key => { :controller => Mithril::Controllers::AbstractController } }; end
      
      it { expect { instance.serialize_callbacks(session, callbacks) }.
        to raise_error Mithril::Controllers::CallbackControllerError,
        /malformed callbacks hash/i }
      
      it "describes the error" do
        begin
          instance.serialize_callbacks(session, callbacks)
        rescue Mithril::Controllers::CallbackControllerError => exception
          exception.errors[callback_key].should include "expected action not to be nil"
        end # begin-rescue
      end # it
    end # describe
    
    describe "serializing a callback" do
      before :each do
        Mithril::Controllers.const_set :FooController, Class.new(Mithril::Controllers::AbstractController)
        Mithril::Controllers.const_set :BarController, Class.new(Mithril::Controllers::AbstractController)
      end # before each
      
      after :each do
        Mithril::Controllers.send :remove_const, :FooController
        Mithril::Controllers.send :remove_const, :BarController
      end # after each
      
      let :callbacks do {
        :foo => { :controller => Mithril::Controllers::FooController, :action => :do_foo },
        :bar => { :controller => Mithril::Controllers::BarController, :action => :do_bar }
      }; end # let actions
      
      let :results do { "foo" => "FooController,do_foo", "bar" => "BarController,do_bar" }; end
      
      it { expect { instance.serialize_callbacks session, callbacks }.not_to raise_error }
      
      it { instance.serialize_callbacks(session, callbacks).should eq results}
      
      context do
        before :each do
          begin; instance.serialize_callbacks(session, callbacks); rescue; end
        end # before each
        
        it { session.should eq Hash.new }
      end # context
    end # describe
  end # describe
  
  describe :deserialize_callbacks do
    before :each do
      Mithril::Controllers.const_set :FooController, Class.new(Mithril::Controllers::AbstractController)
      Mithril::Controllers.const_set :BarController, Class.new(Mithril::Controllers::AbstractController)
    end # before each
    
    after :each do
      Mithril::Controllers.send :remove_const, :FooController
      Mithril::Controllers.send :remove_const, :BarController
    end # after each
    
    let :params do { "foo" => "FooController,do_foo" }; end
    
    it { instance.should respond_to :deserialize_callbacks }
    it { expect { instance.deserialize_callbacks }.to raise_error ArgumentError,
      /wrong number of arguments/i }
    it { expect { instance.deserialize_callbacks(params) }.not_to raise_error }
    
    describe "with no callbacks" do
      let :params do {}; end
      
      it { expect { instance.deserialize_callbacks(params) }.
        to raise_error Mithril::Controllers::CallbackControllerError, /empty callbacks hash/i }
    end # describe
    
    describe "with a nil callback" do
      let :params do { nil => {} }; end
      
      it { expect { instance.deserialize_callbacks(params) }.
        to raise_error Mithril::Controllers::CallbackControllerError, /malformed callbacks hash/i }
      
      it "describes the error" do
        begin
          instance.deserialize_callbacks(params)
        rescue Mithril::Controllers::CallbackControllerError => exception
          exception.errors[""].should include "expected callback not to be nil"
        end # begin-rescue
      end # it describes the error
    end # describe

    describe "with an empty callback" do
      let :params do { "" => {} }; end

      it { expect { instance.deserialize_callbacks(params) }.
        to raise_error Mithril::Controllers::CallbackControllerError, /malformed callbacks hash/i }

      it "describes the error" do
        begin
          instance.deserialize_callbacks(params)
        rescue Mithril::Controllers::CallbackControllerError => exception
          exception.errors[""].should include "expected callback not to be nil"
        end # begin-rescue
      end # it describes the error
    end # describe
    
    describe "with an invalid controller" do
      let :params do { "baz" => "BazController,do_foo" }; end
      
      it { expect { instance.deserialize_callbacks(params) }.
        to raise_error Mithril::Controllers::CallbackControllerError, /malformed callbacks hash/i }
      
      it "describes the error" do
        begin
          instance.deserialize_callbacks(params)
        rescue Mithril::Controllers::CallbackControllerError => exception
          exception.errors["baz"].should include "expected controller to extend AbstractController"
        end # begin-rescue
      end # it describes the error
    end # describe

    describe "with a nil action" do
      let :params do { "foo" => "FooController" }; end
      
      it { expect { instance.deserialize_callbacks(params) }.
        to raise_error Mithril::Controllers::CallbackControllerError, /malformed callbacks hash/i }
      
      it "describes the error" do
        begin
          instance.deserialize_callbacks(params)
        rescue Mithril::Controllers::CallbackControllerError => exception
          exception.errors["foo"].should include "expected action not to be nil"
        end # begin-rescue
      end # it describes the error
    end # describe

    describe "deserializing a valid callback" do
      let :params do { "foo" => "FooController,do_foo", "bar" => "BarController,do_bar" }; end
      
      it { expect { instance.deserialize_callbacks(params) }.not_to raise_error }
      
      context do
        let :callbacks do instance.deserialize_callbacks(params); end
        let :callback_foo do { :controller => Mithril::Controllers::FooController, :action => :do_foo }; end
        let :callback_bar do { :controller => Mithril::Controllers::BarController, :action => :do_bar }; end
        
        it { callbacks[:foo].should eq callback_foo }
        it { callbacks[:bar].should eq callback_bar }
      end # context
    end # describe
  end # describe
  
  describe :get_callbacks do
    let :session do {}; end
    
    it { instance.should respond_to :get_callbacks }
    it { expect { instance.get_callbacks }.to raise_error ArgumentError,
      /wrong number of arguments/i }
    it { expect { instance.get_callbacks(session) }.not_to raise_error }
    it { instance.get_callbacks(session).should be nil }
    
    describe "with a callback set" do
      let :session do { :callback => :callback }; end
      
      it { instance.get_callbacks(session).should be :callback }
    end # describe
  end # describe
  
  describe :set_callbacks do
    let :session do {}; end
    let :callback do :callback; end
    
    it { instance.should respond_to :set_callbacks }
    it { expect { instance.set_callbacks }.to raise_error ArgumentError,
      /wrong number of arguments/i }
    it { expect { instance.set_callbacks(session) }.to raise_error ArgumentError,
      /wrong number of arguments/i }
    it { expect { instance.set_callbacks(session, callback) }.not_to raise_error }
    
    context do
      before :each do instance.set_callbacks(session, callback); end
      
      it { session[:callback].should be callback }
    end # context
  end # describe set_callback
  
  describe :clear_callbacks do
    let :session do { :callback => :callback, :foo => :bar }; end
    
    it { instance.should respond_to :clear_callbacks }
    it { expect { instance.clear_callbacks }.to raise_error ArgumentError,
      /wrong number of arguments/i }
    it { expect { instance.clear_callbacks(session) }.not_to raise_error }
    
    context do
      let :result do { :foo => :bar }; end
      
      before :each do instance.clear_callbacks(session); end
      
      it { session.should eq result }
    end # context
  end # describe
  
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
    
    let :session   do {}; end
    let :callbacks do { "foo" => "FooController,do_foo", "bar" => "BarController,do_bar" }; end
    
    before :each do instance.set_callbacks(session, callbacks); end
    
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
      
      it { expect { instance.invoke_action(session, :foo, arguments) }.not_to raise_error }
      it { instance.invoke_action(session, :foo, arguments).should eq "wibble wobble" }
      
      context do
        before :each do instance.invoke_action(session, :foo, arguments); end
        
        it { session.should eq Hash.new }
      end # context
      
      it { expect { instance.invoke_action(session, :bar, arguments) }.not_to raise_error }
      it { instance.invoke_action(session, :bar, arguments).should eq "wibble wobble" }
      
      context do
        before :each do instance.invoke_action(session, :bar, arguments); end
        
        it { session.should eq Hash.new }
      end # context
    end # describe
    
    describe :invoke_command do
      context do
        let :text do "foo wibble wobble"; end
        
        it { expect { instance.invoke_command(session, text) }.not_to raise_error }
        it { instance.invoke_command(session, text).should eq "wibble wobble" }
        
        context do
          before :each do instance.invoke_command(session, text); end

          it { session.should eq Hash.new }
        end # context
      end # context
      
      context do
        let :text do "bar wibble wobble"; end

        it { expect { instance.invoke_command(session, text) }.not_to raise_error }
        it { instance.invoke_command(session, text).should eq "wibble wobble" }

        context do
          before :each do instance.invoke_command(session, text); end

          it { session.should eq Hash.new }
        end # context
      end # context
    end # describe invoke_command
  end # describe
end # describe
