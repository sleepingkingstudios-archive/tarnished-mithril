# spec/controllers/mixins/module_actions_helper.rb

require 'spec_helper'
require 'controllers/mixins/actions_base_helper'
require 'controllers/mixins/module_helpers_helper'

require 'controllers/abstract_controller'
require 'controllers/mixins/module_actions'
require 'ingot'

shared_examples_for Mithril::Controllers::Mixins::ModuleActions do
  it_behaves_like Mithril::Controllers::Mixins::ActionsBase
  it_behaves_like Mithril::Controllers::Mixins::ModuleHelpers
  
  before :each do
    if described_class.is_a? Class
      Mithril::Mock.const_set :MockModuleActions, Class.new(described_class)
    elsif described_class.is_a? Module
      klass = Class.new
      klass.send :extend, Mithril::Controllers::Mixins::ActionMixin
      klass.send :mixin,  described_class
    
      Mithril::Mock.const_set :MockModuleActions, klass
    end # if-elsif
  end # before each

  after :each do
    Mithril::Mock.send :remove_const, :MockModuleActions
  end # after all

  let :mixin    do Mithril::Mock::MockModuleActions; end
  let :instance do mixin.new; end
  
  let :session do   {}; end
  let :arguments do []; end
  
  describe "close action" do
    it { instance.should have_action :close }
    it { expect { instance.invoke_action(session, :close, arguments) }.not_to raise_error }
    it { instance.invoke_action(session, :close, arguments).should be_a String }
    
    describe "help" do
      let :arguments do %w(help); end
      
      it { instance.invoke_action(session, :close, arguments).should =~ /the close command/i }
    end # describe
    
    describe "when no module is selected" do
      it { instance.invoke_action(session, :close, arguments).should =~
        /currently no module selected/i }
    end # describe
    
    describe "with a module selected" do
      let :ingot do Mithril::Ingot.create :mock_module, Mithril::Controllers::AbstractController; end
      
      after :each do Mithril::Ingot.instance_variable_set :@modules, nil; end
      
      let :session do { :module_key => ingot.key }; end
      
      it { instance.invoke_action(session, :close, arguments).should =~
        /#{ingot.name} module has been closed/i }
      
      context do
        before :each do instance.invoke_action(session, :close, arguments); end
        
        it { session[:module_key].should be nil }
      end # context
    end # describe
  end # describe
end # shared examples
