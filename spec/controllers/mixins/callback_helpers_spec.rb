# spec/controllers/mixins/callback_helpers_spec.rb

require 'spec_helper'
require 'controllers/mixins/callback_helpers_helper'

require 'controllers/mixins/callback_helpers'

describe Mithril::Controllers::Mixins::CallbackHelpers do
  let :described_class do klass = Class.new.send :include, super(); end
  let :instance do described_class.new; end
  
  it_behaves_like Mithril::Controllers::Mixins::CallbackHelpers
end # describe
