# spec/controllers/mixins/module_helpers_helper.rb

require 'spec_helper'

require 'controllers/abstract_controller'
require 'controllers/mixins/module_helpers'
require 'ingots/ingots'

shared_examples_for Mithril::Controllers::Mixins::ModuleHelpers do
  before :each do
    if described_class.is_a? Class
      Mithril::Mock.const_set :MockModuleHelpers, Class.new(described_class)
    elsif described_class.is_a? Module
      klass = Class.new
      klass.send :extend, Mithril::Controllers::Mixins::ActionMixin
      klass.send :mixin,  described_class
    
      Mithril::Mock.const_set :MockModuleHelpers, klass
    end # if-elsif
  end # before each

  after :each do
    Mithril::Mock.send :remove_const, :MockModuleHelpers
  end # after all
  
  let :request  do FactoryGirl.build :request; end
  let :mixin    do Mithril::Mock::MockModuleHelpers; end
  let :instance do mixin.new; end
  
  describe "current_module" do
    before :each do instance.stub :request do nil; end; end
    
    it { instance.should respond_to :current_module }
    it { expect { instance.current_module }.not_to raise_error }
    it { instance.current_module.should be nil }
    
    context "with a module selected" do
      let :ingot do Mithril::Ingots::Ingot.create :mock_module, Mithril::Controllers::AbstractController; end
      
      after :each do Mithril::Ingots::Ingot.instance_variable_set :@modules, nil; end
      
      before :each do
        request.session = { :module_key => ingot.key }
        instance.stub :request do request; end
      end # before each
      
      it { instance.current_module.should be ingot }
    end # context
  end # describe current_module
end # shared examples