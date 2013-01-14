# spec/controllers/mixins/user_helpers_helper.rb

require 'spec_helper'

require 'controllers/mixins/user_helpers'

shared_examples_for Mithril::Controllers::Mixins::UserHelpers do
  before :each do
    if described_class.is_a? Class
      Mithril::Mock.const_set :MockUserHelpers, Class.new(described_class)
    elsif described_class.is_a? Module
      klass = Class.new
      klass.send :extend, Mithril::Controllers::Mixins::ActionMixin
      klass.send :mixin,  described_class
    
      Mithril::Mock.const_set :MockUserHelpers, klass
    end # if-elsif
  end # before each

  after :each do
    Mithril::Mock.send :remove_const, :MockUserHelpers
  end # after all

  let :mixin    do Mithril::Mock::MockUserHelpers; end
  let :instance do mixin.new; end
  
  describe "current user" do
    let :session do {}; end
    
    it { instance.should respond_to :current_user }
    it { expect { instance.current_user(session) }.not_to raise_error }
    it { instance.current_user(session).should be nil }
    
    context "with a user selected" do
      let :user do FactoryGirl.create :user; end
      let :session do { :user_id => user.id }; end
      
      it { instance.current_user(session).should eq user }
    end # context
  end # describe current user
end # shared examples
