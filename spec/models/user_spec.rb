require 'spec_helper'

describe User do
  it "has a valid factory" do
    create(:user).should be_valid
  end
  
  it "is invalid without a name" do
    build(:user, fullname: nil).should_not be_valid
  end
   
  describe "validates email address" do
    before do
      @user = build(:user)
    end
  
    context "when email is empty" do
      it "should be empty" do
        @user.email = nil
        @user.should_not be_valid
      end
    end

    context "when email format is invalid" do
      it "should be invalid" do
        addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                       foo@bar_baz.com foo@bar+baz.com]
        addresses.each do |invalid_address|
          @user.email = invalid_address
          @user.should_not be_valid
        end      
      end
    end

    context "when email format is valid" do
      it "should be valid" do
        addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
        addresses.each do |valid_address|
          @user.email = valid_address
          @user.should be_valid
        end      
      end
    end
  end
end
