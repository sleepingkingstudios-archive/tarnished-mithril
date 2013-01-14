# spec/controller/session_controller_spec.rb

require 'spec_helper'
require 'controllers/mixins/help_actions_helper'
require 'controllers/mixins/session_actions_helper'

require 'controllers/session_controller'

describe Mithril::Controllers::SessionController do
  it_behaves_like Mithril::Controllers::Mixins::HelpActions
  it_behaves_like Mithril::Controllers::Mixins::SessionActions
end # describe
