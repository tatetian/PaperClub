require 'spec_helper'

describe TagsController do
  before :each do
    # Init variables
    @me   = create(:me)
    @club = create(:club)
    @membership = create(:membership, user_id: @me.id, club_id: @club.id)
    @paper = create(:paper, club_id: @club.id)
    @tag  = create(:tag, club_id: @club.id)
    @collection = create(:collection, tag_id: @tag.id, paper_id: @paper.id)
    # Login
    cookies[:remember_token] = @me.remember_token 
  end

  describe "without paper_id" do
    context "GET 'index'" do
      it "renders a JSON" do
        get 'index', club_id: @club.id
        response.body.should == @club.tags.to_json
      end
    end

    context "POST 'create'" do
      it "creates a tag" do
        post 'create', club_id: @club.id, name: "New Tag"
        @club.tags.find_by_name("new tag").should_not == nil
      end

      it "renders a JSON" do
        post 'create', club_id: @club.id, name: "New Tag"
        response.body.should == {name: "new tag", club_id:@club.id}.to_json
      end
    end

    context "DELETE 'destroy'" do
      it "destroys a tag" do
        delete 'destroy', id: @tag
        @club.tags.should == []
      end

      it "removes collections as well" do
        delete 'destroy', id: @tag
        lambda { @collection.reload }.should raise_error(ActiveRecord::RecordNotFound)
      end
  
      it "renders a JSON" do
        delete 'destroy', id: @tag
        response.body.should == @tag.to_json
      end
    end
  end

  describe "with paper_id" do
    context "GET 'index'" do
      it "renders a JSON" do
        get 'index', paper_id: @paper.id
        response.body.should == @paper.tags.to_json
      end
    end

    context "POST 'create'" do
      it "creates a tag" do
        post 'create', paper_id: @paper.id, name: "New Tag"
        @paper.tags.find_by_name("new tag").should_not == nil
      end

      it "renders a JSON" do
        post 'create', paper_id: @paper.id, name: "New Tag"
        response.body.should == {name: "new tag", club_id:@club.id}.to_json
      end
    end

    context "DELETE 'destroy'" do
      it "removes a tag from a paper" do
        delete 'destroy', paper_id: @paper.id, id: @tag
        @paper.tags.should == []
      end

      it "removes collection instead of tag" do
        delete 'destroy', paper_id: @paper.id, id: @tag
        # Collection should be destroyed already
        lambda { @collection.reload }.should raise_error(ActiveRecord::RecordNotFound)
        # Check tag is not destroyed
        @tag.reload
      end
  
      it "renders a JSON" do
        delete 'destroy', paper_id: @paper.id, id: @tag
        response.body.should == @tag.to_json
      end
    end
  end
end
