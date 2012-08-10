require 'spec_helper'

describe Paper do
  before do
    @paper = create(:paper)
  end

  subject { @paper }

  it { should respond_to(:title) }
  it { should respond_to(:pub_date) }
  it { should respond_to(:doc_hash) }
  it { should respond_to(:uploader) }
  it { should respond_to(:club_id) }

  it { should be_valid }

  it "has tags" do
    tag = create(:tag)
    collection = create(:collection, tag_id: tag.id, paper_id: @paper.id)
    @paper.tags.should == [tag]
  end

  it "has notes" do
    note = create(:note, paper_id: @paper.id)
    @paper.notes.should == [note]
  end 
end
