class Api::ClubsController < ApplicationController

  # TODO: role!!!
  # TODO: destroy

  # List all clubs of current user
  #
  # URL     GET /api/clubs
  # ROLE    member
  def index
    render :json => current_user.clubs
  end

  # Show details of a club
  #
  # URL     GET /api/club/<club_id>
  # ROLE    member
  def show
    render :json => current_user.clubs.find(params[:id])
  end

  # Create a new club
  #
  # URL     POST /clubs
  # PARAMS  club[:name]
  #         club[:description]
  #         invititation_emails  -- array
  # ROLE    member
  def create
    club = Club.create(params[:club])
    if club
      if Membership.create(club_id: club.id, user_id: current_user.id)
        emails = params[:invitation_emails]
        if emails
          emails.each { |e| 
            Invitation.create( invitor_id: current_user.id,
                               invitee_email: e,
                               club_id: club.id, 
                               role: "member")
          }
        end
        render :json => club
      else
        club.destroy
        error("failed to add a new club to the user")
      end
    else
      error("failed to create a new club")
    end
  end

  # Update the details of a club
  #
  # URL     PUT /club/<club_id>
  # PARAMS  club[name]
  #         club[description]
  # ROLE    admin
  def update
    #if current_user.role == "admin"
    club = current_user.clubs.find(params[:id])
    if club
      if club.update_attributes(params[:club])
        render :json => club
      else
        error "Failed to update record"
      end
    else
      error "You don't have access to this club"
    end
  end

  # Destroy of a club
  # URL     DEL /club/<club_id>
  # ROLE    admin
  def destroy
  end
end
