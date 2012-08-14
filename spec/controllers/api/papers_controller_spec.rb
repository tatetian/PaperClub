require 'spec_helper'

describe Api::PapersController do
  before :each do
    # Init variables
    @me   = create(:me)
    @club = create(:club)
    @membership = create(:membership, user_id: @me.id, club_id: @club.id)
    @paper = create(:paper, club_id: @club.id)
    # Login
    cookies[:remember_token] = @me.remember_token
  end

  describe "GET 'index'" do
    it "renders a JSON" do
      get 'index', club_id: @club.id
      response.body.should == [@paper].to_json
    end
  end
  
  describe "GET 'show'"  do
    it "renders a JSON" do
      get 'show', id: @paper
      response.body.should == @paper.to_json
    end
  end

  describe "PUT 'update'" do
    it "renders a JSON" do
      put  'update', id: @paper, paper: { title: "New Title"}
      @paper.reload
      @paper.title.should == "New Title"
      response.body.should == @paper.to_json
    end
  end

  describe "DELETE 'destroy'" do
    it "renders a JSON" do
      delete 'destroy', id: @paper
      response.body.should == { id: @paper.id }.to_json
    end

    it "destroys a paper" do
      delete 'destroy', id: @paper
      lambda { Paper.find(@paper.id) }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
