# spec/controllers/abstract_controller_spec.rb

require 'spec_helper'
require 'controllers/abstract_controller_helper'

require 'controllers/abstract_controller'

module Mithril
  module Mock; end
end # module

describe Mithril::Controllers::AbstractController do
  it_behaves_like Mithril::Controllers::AbstractController
end # describe
