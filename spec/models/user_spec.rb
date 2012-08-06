require 'spec_helper'

describe User do
  before do
    password = "123456"
    @user = create(:user, password: password, password_confirmation: password)
  end

  subject { @user }

  it { should respond_to(:fullname) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:authenticate) }

  it { should be_valid }

  it "is invalid without a name" do
    @user.fullname = nil
    @user.should_not be_valid
  end 

  describe "validates password" do
    before do
      password = "123456"
      @user = create(:user, password: password, password_confirmation: password)
    end

    context "when password is empty" do
      it "should be invalid" do
        @user.password = ""
        @user.should_not be_valid
      end
    end

    context "when length is less than 6 characters" do
      it "should be invalid" do
        @user.password = "123"
        @user.should_not be_valid
      end
    end

    context "when passwords mismatch" do
      it "should be invalid" do
        @user.password_confirmation = "mismatch"
        @user.should_not be_valid
      end
    end  
  end

  describe "validates email address" do
    before do
      password = "123456"
      @user = create(:user, password: password, password_confirmation: password)
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

    context "when email is duplicated" do
      it "should not be valid" do
        build(:user, email: @user.email.upcase).should_not be_valid
      end
    end
  end
end
