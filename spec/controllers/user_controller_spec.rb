require 'spec_helper'
require 'json'


describe UserController do
  describe "GET 'index'" do
    #it "returns http success" do
    #  get 'index'
    #  response.should be_success
    #end
  end

  describe "POST 'create'" do
    it "creates a new user" do
      # User.count increases by one 
      expect {
        post :create, user: attributes_for(:user)
      }.to change(User, :count).by(1)
    end

    it "renders a JSON" do
      # Send request
      user = attributes_for(:user)
      post :create, user: user
      # Check response
      #   password & password_confirmation should not appear in response
      user.delete(:password)
      user.delete(:password_confirmation)
      response.body.should == user.to_json
    end
  end

  describe "PUT 'update'" do
    before :each do
      @me = create(:me)
    end

    it "updates fullname" do
      # Send request to update fullname as Wen Xin
      put :update, id: @me, user: attributes_for(:me, fullname: "Wen Xin")
      # Check database
      @me.reload 
      @me.fullname.should eq("Wen Xin")
      # Check response
      response.body.should == @me.to_hash.to_json
    end

    it "updates email" do
      # Send request to update fullname as Wen Xin
      put :update, id: @me, user: attributes_for(:me, email: "new@gmail.com")
      # Check database
      @me.reload 
      @me.email.should eq("new@gmail.com")
      # Check response
      response.body.should == @me.to_hash.to_json
    end   

    it "fails to update" do
      # Send request that is invalid
      put :update, id: @me, user: attributes_for(:me, email: "not_a_email")
      # Check database
      old_email = @me.email
      @me.reload 
      @me.email.should eq(old_email)
      # Check response
      response.body.should == "{}"
    end
  end


end
