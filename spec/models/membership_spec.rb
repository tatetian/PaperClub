require 'spec_helper'

describe Membership do
  before do
    @user = create(:user)
    @club = create(:club)
    @membership = create(:membership, user_id:@user.id, club_id:@club.id)
  end

  subject { @membership }

  it { should respond_to(:role) }

  it "belongs to user" do
    @user.memberships.should == [@membership]
  end

  it "belongs to club" do
    @club.memberships.should == [@membership]
  end
end
