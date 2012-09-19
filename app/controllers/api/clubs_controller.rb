class Api::ClubsController < ApplicationController

  # TODO: role!!!

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
  # URL     POST /api/clubs
  # PARAMS  club[:name]
  #         club[:description]
  #         invititation_emails  -- array
  # ROLE    member
  def create
    club = Club.create(params[:club])
    if club
      if Membership.create(club_id: club.id, user_id: current_user.id, role: "admin")
        _send_invitations params[:invitation_emails], club.id

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
  # URL     PUT /api/club/<id>
  # PARAMS  club[name]
  #         club[description]
  # ROLE    admin
  def update
    #if current_user.role == "admin"
    club = current_user.clubs.find_by_id(params[:id])
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

  # Quit or/and destroy a club
  # URL     DEL /api/club/<id>
  # ROLE    admin
  # PARAMS  delete_club
  def destroy
    club = current_user.clubs.find_by_id(params[:id])
    if club
      membership = current_user.memberships.find_by_club_id(club.id) 
      # Quit
      if membership and membership.destroy
        # Delete club (optional) if you're an admin
        club.destroy if params[:delete_club] and membership.role == "admin"

        render :json => { id: club.id }
        return
      end
    end
    error "Failed to quite or delete the club"
  end

  # Send invitation to people to join this club
  # URL     POST /api/club/<id>/invitation
  # ROLE    member
  # PARAMS  emails
  def invite
    club = current_user.clubs.find_by_id(params[:id])
    if club
      _send_invitations params[:emails], club.id
      render :json => {}
      return
    end
    error "Failed to send"
  end

private
  def _send_invitations(emails, club_id)
    if emails
      emails.each { |e| 
        Invitation.create( invitor_id: current_user.id,
                           invitee_email: e,
                           club_id: club_id, 
                           role: "member")
      }
    end
  end
end
