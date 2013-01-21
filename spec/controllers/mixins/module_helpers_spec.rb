# spec/controllers/mixins/module_helpers_spec.rb

require 'spec_helper'
require 'controllers/mixins/module_helpers_helper'

require 'controllers/mixins/module_helpers'

describe Mithril::Controllers::Mixins::ModuleHelpers do
  let :request do FactoryGirl.build :request; end
  let :described_class do Class.new.send :include, super(); end
  let :instance do
    instance = described_class.new
    instance.tap do |i| i.stub :request do request end; end
  end # let
  
  it_behaves_like Mithril::Controllers::Mixins::ModuleHelpers
end # describe
