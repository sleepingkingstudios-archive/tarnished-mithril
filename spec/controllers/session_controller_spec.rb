# spec/controller/session_controller_spec.rb

require 'spec_helper'
require 'controllers/abstract_controller_helper'
require 'controllers/mixins/help_actions_helper'
require 'controllers/mixins/session_actions_helper'

require 'controllers/session_controller'

describe Mithril::Controllers::SessionController do
  let :request do FactoryGirl.build :request end
  let :described_class do Class.new super(); end
  let :instance do described_class.new request; end
  
  it_behaves_like Mithril::Controllers::AbstractController
  it_behaves_like Mithril::Controllers::Mixins::HelpActions
  it_behaves_like Mithril::Controllers::Mixins::SessionActions
end # describe
