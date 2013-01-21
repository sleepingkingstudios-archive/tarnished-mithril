# spec/controllers/mixins/actions_base_spec.rb

require 'spec_helper'
require 'controllers/mixins/actions_base'
require 'controllers/mixins/actions_base_helper'

require 'mixin'

describe Mithril::Controllers::Mixins::ActionsBase do
  let :described_class do
    klass = Class.new.extend Mixin
    klass.send :mixin, super();
    klass
  end # let
  let :instance do described_class.new; end
  
  it_behaves_like Mithril::Controllers::Mixins::ActionsBase
end # describe
