# spec/controllers/user_controller_spec.rb

require 'spec_helper'
require 'controllers/mixins/help_actions_helper'
require 'controllers/mixins/user_actions_helper'

require 'controllers/user_controller'

describe Mithril::Controllers::UserController do
  it_behaves_like Mithril::Controllers::Mixins::HelpActions
  it_behaves_like Mithril::Controllers::Mixins::UserActions
end # describe
