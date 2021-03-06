# spec/controllers/mixins/module_actions_helper.rb

require 'spec_helper'
require 'controllers/mixins/actions_base_helper'
require 'controllers/mixins/module_helpers_helper'

require 'controllers/abstract_controller'
require 'controllers/mixins/module_actions'
require 'ingots/ingots'
require 'request'

shared_examples_for Mithril::Controllers::Mixins::ModuleActions do
  it_behaves_like Mithril::Controllers::Mixins::ActionsBase
  it_behaves_like Mithril::Controllers::Mixins::ModuleHelpers
  
  let :arguments do []; end
  
  describe "close action" do
    it { instance.should have_action :close }
    it { expect { instance.invoke_action(:close, arguments) }.not_to raise_error }
    it { instance.invoke_action(:close, arguments).should be_a String }
    
    describe "help" do
      let :arguments do %w(help); end
      
      it { instance.invoke_action(:close, arguments).should =~ /the close command/i }
    end # describe
    
    describe "when no module is selected" do
      it { instance.invoke_action(:close, arguments).should =~
        /currently no module selected/i }
    end # describe
    
    describe "with a module selected" do
      let :ingot do
        Mithril::Ingots::Ingot.create :mock_module, Mithril::Controllers::AbstractController
      end # let
      after :each do Mithril::Ingots::Ingot.instance_variable_set :@modules, nil; end
      
      let :request do FactoryGirl.build :request, :session => { :module_key => ingot.key }; end
      before :each do instance.stub :request do request; end; end # before :each
      
      it { instance.invoke_action(:close, arguments).should =~
        /#{ingot.name} module has been closed/i }
      
      context do
        before :each do instance.invoke_action(:close, arguments); end
        
        it { request.session[:module_key].should be nil }
      end # context
    end # describe
  end # describe
end # shared examples
