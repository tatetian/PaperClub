require 'spec_helper'

describe Paper do
  before do
    @user = create(:user)
    @paper = create(:paper, uploader_id: @user.id)
    @metadata = create(:metadata, uuid: @paper.uuid)
  end

  subject { @paper }

  it { should respond_to(:title) }
  it { should respond_to(:pub_date) }
  it { should respond_to(:uuid) }
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

  it "has news" do
    @paper.news.should == News.find_by_paper_id(@paper.id)
  end
end
