require 'spec_helper'

describe Invitation do
  include EmailSpec::Helpers
  include EmailSpec::Matchers

  before do
    @user = create(:user)
    @club = create(:club)
    @membership = create(:membership, user_id:@user.id, club_id:@club.id)
    @invitation = create(:invitation, invitor_id: @user.id, club_id:@club.id)
  end

  subject { @invitation }

  it { should respond_to(:invitor_id) }
  it { should respond_to(:invitee_email) }
  it { should respond_to(:role) }
  it { should respond_to(:club_id) }

  # Invitation email deliver
  describe "email sent" do
    before do 
      @email = ActionMailer::Base.deliveries.last
    end
  
    subject { @email }

    it { should be_delivered_to @invitation.invitee_email }
    it { should have_subject /#{@user.fullname}/ }
    it { should have_subject /invites/ }
    it { should have_body_text /join/ }
    it { should have_body_text /PaperClub/ }
    it { should have_body_text /link/ }
  end
end
