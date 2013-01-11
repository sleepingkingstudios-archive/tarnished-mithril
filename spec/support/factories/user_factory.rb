# spec/support/factories/user_factory.rb

require 'factory_girl'

require 'models/user'

FactoryGirl.define do
  sequence :username do |index| "user_#{index}"; end
  sequence :password do |index|
    chars = [*0..9].map(&:to_s) + [*?a..?z, *?A..?Z]
    [*0..rand(6..18)].inject("") {|m, n| m + chars[rand(62)] }
  end # sequence password
  
  factory :user, class: Mithril::Models::User do
    
  end # factory
end # define
