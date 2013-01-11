# spec/models/user_spec.rb

require 'spec_helper'

require 'models/user'

describe Mithril::Models::User do
  it { described_class.create! }
end # describe
