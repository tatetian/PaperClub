require 'spec_helper'

describe SessionsController do
  describe "POST 'create'" do
    before :each do
      @me = create(:me)
    end

    it "signs in" do
      # login
      post :create, session: { :email => @me.email, :password => "123456"}
      # check cookie
      response.cookies['remember_token'].should == @me.remember_token
    end
  end

  describe "DELETE 'destroy'" do
    before :each do
      @me = create(:me)
    end

    it "signs out" do
      # login
      delete :destroy
      # check cookie
      response.cookies['remember_token'].should == nil
    end
  end
end
