# spec/controllers/mixins/module_actions_spec.rb

require 'spec_helper'
require 'controllers/mixins/module_actions_helper'

require 'controllers/mixins/module_actions'

describe Mithril::Controllers::Mixins::ModuleActions do
  let :request do FactoryGirl.build :request; end
  let :described_class do
    klass = Class.new.extend Mithril::Controllers::Mixins::ActionMixin
    klass.send :mixin, super()
    klass
  end # let
  let :instance do
    instance = described_class.new
    instance.tap do |i| i.stub :request do request end; end
  end # let
  
  it_behaves_like Mithril::Controllers::Mixins::ModuleActions
end # describe
