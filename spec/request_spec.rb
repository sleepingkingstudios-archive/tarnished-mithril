# spec/request_spec.rb

require 'spec_helper'

require 'request'

describe Mithril::Request do
  let :request do described_class.new; end
  
  describe :session do
    it { request.should respond_to :session }
    it { expect { request.session }.not_to raise_error }
    it { request.session.should be nil }
  end # describe session
  
  describe :session= do
    let :hsh_value do {}; end
    
    it { request.should respond_to :session= }
    it { expect { request.session = hsh_value }.not_to raise_error }
    it { (request.session = hsh_value).should be hsh_value }
    
    context "when set" do
      before :each do request.session = hsh_value; end
      
      it { request.session.should be hsh_value }
    end # context
  end # describe session=
  
  describe :text do
    it { request.should respond_to :text }
    it { expect { request.text }.not_to raise_error }
    it { request.text.should be nil }
  end # describe :text

  describe :text= do
    let :str_value do ""; end

    it { request.should respond_to :text= }
    it { expect { request.text = str_value }.not_to raise_error }
    it { (request.text = str_value).should be str_value }

    context "when set" do
      before :each do request.text = str_value; end

      it { request.text.should be str_value }
    end # context
  end # describe session=
  
  describe :user do
    it { request.should respond_to :user }
    it { expect { request.user }.not_to raise_error }
    it { request.user.should be nil }
    
    describe "with an invalid user id" do
      let :user_id do rand(2**16); end
      let :session do { :user_id => user_id }; end
      
      before :each do request.session = session; end
      
      it { expect { request.user }.not_to raise_error }
      it { request.user.should be nil }
    end # describe
    
    describe "with a valid user id" do
      let :user do FactoryGirl.create :user; end
      let :session do { :user_id => user.id }; end
      
      before :each do request.session = session; end
      
      it { expect { request.user }.not_to raise_error }
      it { request.user.should eq user }
    end # describe
  end # describe user
  
  describe :user= do
    it { request.should_not respond_to :user= }
    it { expect { request.user = nil }.to raise_error NoMethodError }
  end # describe user=
end # describe
