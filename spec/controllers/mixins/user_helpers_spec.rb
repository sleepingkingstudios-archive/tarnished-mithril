# spec/controllers/mixins/user_helpers_spec.rb

require 'spec_helper'
require 'controllers/mixins/user_helpers_helper'

require 'controllers/mixins/user_helpers'

describe Mithril::Controllers::Mixins::UserHelpers do
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
  
  it_behaves_like Mithril::Controllers::Mixins::UserHelpers
end # describe
