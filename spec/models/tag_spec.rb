require 'spec_helper'

describe Tag do
  before do
    @club = create(:club)
    @tag = create(:tag, club_id: @club.id)
  end

  subject { @tag }

  it { should respond_to(:name) } 
  it { should respond_to(:club) }

  it { should be_valid }

  it "belongs to a club" do
    @tag.club.should == @club
  end

  it "has papers" do
    paper = create(:paper)
    collection = create(:collection, tag_id: @tag.id, paper_id: paper.id)
    @tag.papers.should == [paper]
  end 
end
