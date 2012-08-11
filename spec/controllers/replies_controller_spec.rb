require 'spec_helper'

describe RepliesController do
  before :each do
    # Init variables
    @me   = create(:me)
    @club = create(:club)
    @membership = create(:membership, user_id: @me.id, club_id: @club.id)
    @paper = create(:paper, club_id: @club.id)
    @note = create(:note, paper_id: @paper.id, user_id: @me)
    @reply = create(:reply, note_id: @note.id, user_id: @me) 
    # Login
    cookies[:remember_token] = @me.remember_token
  end

  describe "GET 'index'" do
    it "renders a JSON" do
      get 'index', note_id: @note
      response.body.should == [@reply].to_json
    end
  end 

  describe "POST 'create'" do
    it "renders a JSON" do
      post 'create', note_id: @note, content: "Something"
      new_reply = Reply.find_by_content("Something")
      @note.replies.size.should == 2
      response.body.should == new_reply.to_json
    end
  end

  describe "DELETE 'destroy'" do
    it "renders a JSON" do
      delete 'destroy', id: @reply
      response.body.should == { id: @reply.id }.to_json
    end

    it "delete a note" do
      delete 'destroy', id: @reply
      lambda { Note.find(@reply.id) }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end

end
