require 'spec_helper'

describe Api::NotesController do
  before :each do
    # Init variables
    @me   = create(:me)
    @club = create(:club)
    @membership = create(:membership, user_id: @me.id, club_id: @club.id)
    @paper = create(:paper, club_id: @club.id)
    @note = create(:note, paper_id: @paper.id, user_id: @me)
    # Login
    cookies[:remember_token] = @me.remember_token
  end

  describe "with paper_id" do
    context "GET 'index'" do
      it "renders a JSON" do
        get 'index', paper_id: @paper
        response.body.should == @paper.notes.to_json
      end
    end

    context "POST 'create'" do
      it "renders a JSON" do
        post 'create', paper_id: @paper, content: "Something", position: "Page 1"
        new_note = Note.find_by_content("Something")
        @paper.notes.size.should == 2
        response.body.should == new_note.to_json
      end
    end
  end

  describe "without paper_id" do
    context "GET 'show'" do
    end

    context "PUT 'update'" do
      it "renders a JSON" do
        put 'update', id: @note, note: { content: "Something new" }
        @note.reload
        response.body.should == @note.to_json 
      end
    end

    context "DELETE 'destroy'" do
      it "renders a JSON" do
        delete 'destroy', id: @note
        response.body.should == { id: @note.id }.to_json
      end

      it "delete a note" do
        delete 'destroy', id: @note
        lambda { Note.find(@note.id) }.should raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
