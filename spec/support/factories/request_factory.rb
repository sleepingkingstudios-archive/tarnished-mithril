# spec/support/factories/user_factory.rb

require 'factory_girl'

require 'request'

FactoryGirl.define do
  factory :request, class: Mithril::Request do
    session Hash.new
  end # factory
end # define
