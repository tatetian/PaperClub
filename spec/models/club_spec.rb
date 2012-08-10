require 'spec_helper'

describe Club do
  before do
    @club = create(:club)
  end

  subject { @club }

  it { should respond_to(:description) }
  it { should respond_to(:name) }

  it "has many tags" do
    tag = create(:tag, club_id: @club.id)
    @club.tags.should == [tag]
  end

  it "has many users" do
    user = create(:user)
    membership = create(:membership, user_id: user.id, club_id: @club.id)
    @club.users.should == [user]
  end
end
