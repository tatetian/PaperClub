require 'spec_helper'

describe Api::ClubsController do
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
    before do
      @email = attributes_for(:invitation)[:invitee_email],
      ActionMailer::Base.deliveries = []
    end

    it "creates a new club" do
      post 'create', club: attributes_for(:club, name: 'Another Club'), invitation_emails: [@email]
      @me.clubs.size.should == 2 
    end

    it "renders a JSON" do
      post 'create', club: attributes_for(:club, name: 'Another Club'), invitation_emails: [@email]
    end

    it "sends emails" do
      post 'create', club: attributes_for(:club, name: 'Another Club'), invitation_emails: [@email]
      ActionMailer::Base.deliveries.size.should == 1 
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

  describe "DELETE 'destroy'" do
    it "quits a club" do
      @me.clubs.should == [@club]
      delete 'destroy', id: @club
      @me.reload
      @me.clubs.should == []
      @club.reload.should_not == nil
    end
    
    it "deletes a club" do
      delete 'destroy', id: @club, delete_club: true
      expect { @club.reload }.to raise_error 
    end
  end
end
