# spec/controllers/mixins/help_actions_spec.rb

require 'spec_helper'
require 'controllers/mixins/help_actions_helper'

require 'controllers/mixins/help_actions'

describe Mithril::Controllers::Mixins::HelpActions do
  let :described_class do
    klass = Class.new.extend Mithril::Controllers::Mixins::ActionMixin
    klass.send :mixin, super()
    klass
  end # let
  let :instance do described_class.new; end
  
  it_behaves_like Mithril::Controllers::Mixins::HelpActions
end # describe
