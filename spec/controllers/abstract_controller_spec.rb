# spec/controllers/abstract_controller_spec.rb

require 'spec_helper'
require 'controllers/abstract_controller_helper'

require 'controllers/abstract_controller'

describe Mithril::Controllers::AbstractController do
  let :request do FactoryGirl.build :request end
  let :described_class do Class.new super(); end
  let :instance do instance = described_class.new request; end
  
  it_behaves_like Mithril::Controllers::AbstractController
end # describe
