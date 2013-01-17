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
  
  let :request  do FactoryGirl.build :request end
  let :mixin    do Mithril::Mock::MockUserHelpers; end
  let :instance do mixin.new; end
  
  describe "current user" do
    before :each do instance.stub :request do nil; end; end
    
    it { instance.should respond_to :current_user }
    it { expect { instance.current_user }.not_to raise_error }
    it { instance.current_user.should be nil }
    
    context "with a user selected" do
      let :user do FactoryGirl.create :user; end
      
      before :each do
        request.session = { :user_id => user.id }
        instance.stub :request do request; end
      end # before each
      
      it { instance.current_user.should eq user }
    end # context
  end # describe current user
end # shared examples
