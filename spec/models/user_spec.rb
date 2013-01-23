# spec/models/user_spec.rb

require 'spec_helper'

require 'models/user'

describe Mithril::Models::User do
  it { FactoryGirl.create(:user) }
  
  describe :creation do
    let :user do described_class.new; end
  
    describe :username do
      it { user.should respond_to :username }
    
      context do
        let :old_username do FactoryGirl.generate(:username); end
        let :new_username do FactoryGirl.generate(:username); end
        let :user do described_class.new :username => old_username; end
      
        it { expect { user.username }.not_to raise_error }
      
        it { expect { user.username = new_username }.not_to raise_error }
      
        it { user.username.should == old_username }
      
        context "updated" do
          before :each do user.username = new_username; end
        
          it { user.username.should == new_username }
        end # context
      end # context
    end # describe name
  
    describe "validation" do
      let :user_name do FactoryGirl.generate :username; end
      let :password  do FactoryGirl.generate :password; end
      let :confirm   do password; end
    
      let :user do
        described_class.new :username => user_name, :password => password,
          :password_confirmation => confirm
      end # let
    
      it { expect { user.save }.not_to raise_error }
      it { user.should be_valid }
      it { user.save.should be true }
    
      describe "name must be present" do
        before :each do user.username = nil; user.valid?; end
      
        it { user.should_not be_valid }
        it { user.save.should be false }
        it { user.errors.messages[:username].should include_matching Regexp.new("can't be blank") }
      end # describe name must be present
    
      describe "name must be unique" do
        let :new_password do FactoryGirl.generate(:password); end
        before :each do
          described_class.create :username => user_name, :password => new_password,
            :password_confirmation => new_password
          user.valid?
        end # before each
      
        it { user.should_not be_valid }
        it { user.save.should be false }
        it { user.errors.messages[:username].should include_matching Regexp.new("has already been taken") }
      end # describe name must be unique
    
      describe "password must be present" do
        before :each do user.password = nil; user.valid?; end
      
        it { user.should_not be_valid }
        it { user.save.should be false }
        it { user.errors.messages[:password].should include_matching Regexp.new("can't be blank") }
      end # describe name must be present

      describe "password confirmation must be present" do
        before :each do user.password_confirmation = nil; user.valid?; end

        it { user.should_not be_valid }
        it { user.save.should be false }
        it { user.errors.messages[:password_confirmation].should include_matching Regexp.new("can't be blank") }
      end # describe name must be present
    
      describe "password must match confirmation" do
        before :each do user.password_confirmation = "xyzzy"; user.valid?; end

        it { user.should_not be_valid }
        it { user.save.should be false }
        it { user.errors.messages[:password].should include_matching Regexp.new("doesn't match confirmation") }
      end # describe password must match confirmation
    end # describe validation
    
    describe :authenticate do
      let :username do FactoryGirl.generate :username; end
      let :password do FactoryGirl.generate :password; end
      
      before :each do
        user.username = username
        user.password = password
        user.password_confirmation = password
        user.save!
      end # before each
      
      it { user.authenticate(password).should_not eq false }
    end # describe
  end # describe creation
end # describe
