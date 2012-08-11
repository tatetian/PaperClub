require 'spec_helper'

describe NotesController do
  before :each do
    # Init variables
    @me   = create(:me)
    @club = create(:club)
    @membership = create(:membership, user_id: @me.id, club_id: @club.id)
    @paper = create(:paper, club_id: @club.id)
    @note = create(:note, paper_id: @paper_id, user_id: @me)
    # Login
    cookies[:remember_token] = @me.remember_token
  end

  describe "with paper_id" do
    context "GET 'index'" do
      it "renders a JSON" do
        get 'index', club_id: @club, paper_id: @paper
        response.body.should == @paper.notes.to_json
      end
    end

    context "POST 'create'" do
    end
  end

  describe "without paper_id" do
    context "GET 'show'" do
    end

    context "PUT 'update'" do
    end

    context "DELETE 'destroy'" do
    end
  end
end
