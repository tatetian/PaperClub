require "spec_helper"

describe Notifer do
  describe "send_invitation" do
    before do
      @user = create(:user)
      @club = create(:club)
      @membership = create(:membership, user_id:@user.id, club_id:@club.id)
      @invitation = build(:invitation, invitor_id: @user.id, club_id:@club.id)
      @invitor = @user
    end

    let(:mail) { Notifer.send_invitation(@invitation) }

    it "renders the headers" do
      mail.subject.should match(/.*#{@invitor.fullname}.*invite.*/)
      mail.to.should eq([@invitation.invitee_email])
      mail.from.should eq(["paperclub.mailer@gmail.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match(/invite/)
      mail.body.encoded.should match(/#{@invitor.fullname}/)
      mail.body.encoded.should match(/PaperClub/)
      mail.body.encoded.should match(/#{@club.name}/)
    end
  end

end
