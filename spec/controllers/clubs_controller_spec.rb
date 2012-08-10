require 'spec_helper'

describe ClubsController do
  before :each do
    # Init variables
    @me   = create(:me)
    @club = create(:club)
    @membership = create(:membership, user_id: @me.id, club_id: @club.id)
    # Login
    cookies[:remember_token] = @me.remember_token
  end

  describe "GET 'index'" do
    it "renders a JSON" do
      get 'index'
      response.body.should == [@club].to_json
    end
  end

  describe "GET 'show'" do
    it "renders a JSON" do
      get 'show', id: @club.id
      response.body.should == @club.to_json
    end
  end

  describe "POST 'create'" do
    it "creates a new club" do
      post 'create', club: attributes_for(:club, name: 'Another Club')
      @me.clubs.size.should == 2
    end

    it "renders a JSON" do
      post 'create', club: attributes_for(:club, name: 'Another Club')
    end
  end

  describe "PUT 'update'" do
    it "renames the club" do
      put 'update', id: @club, club: { name: 'A New Club Name'}
      @club.reload
      @club.name.should == 'A New Club Name' 
    end

    it "renders a JSON" do
      put 'update', id: @club, club: { name: 'A New Club Name'}
      @club.reload
      response.body.should == @club.to_json
    end
  end
end