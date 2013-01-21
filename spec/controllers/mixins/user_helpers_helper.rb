# spec/controllers/mixins/user_helpers_helper.rb

require 'spec_helper'

require 'controllers/mixins/user_helpers'

shared_examples_for Mithril::Controllers::Mixins::UserHelpers do
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
