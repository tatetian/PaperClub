class Api::RepliesController < ApplicationController
  # List all replies of the note
  #
  # URL     GET /note/<note_id>/replies
  def index
    begin
      # Find the paper
      note = Note.find(params[:note_id])
      # Authenticate
      can_access_club?(Paper.find(note.paper_id).club_id)

      render :json => note.replies
    rescue ActiveRecord::RecordNotFound
      error "Can't acess the club or the paper"
    end
  end

  # Create a reply for the note
  #
  # URL     POST /note/<note_id>/replies
  # PARAMS  content
  def create
    begin
      # Find the paper
      note = Note.find(params[:note_id])
      # Authenticate
      can_access_club?(Paper.find(note.paper_id).club_id)
      # New note
      new_reply = Reply.create(content: params[:content],
                               user_id: current_user.id,
                               note_id: note.id)
      if new_reply
        render :json => new_reply
      else
        error "Failed to create a new reply"
      end
    rescue ActiveRecord::RecordNotFound
      error "Can't access the club or the paper or the note"
    end
  end

  # Destroy a reply
  #
  # URL     DELETE /reply/
  # PARAMS  id
  def destroy
    begin
      # Find reply
      reply = Reply.find(params[:id]) 
      # Authenticate
      can_access_club?(Paper.find(Note.find(reply.note_id).paper_id).club_id)
      
      if reply.destroy
        render :json => { id: reply.id }
      else
        error "Failed to destroy the reply" 
      end
    rescue ActiveRecord::RecordNotFound
      error "Can't access the club or the paper or the note"
    end
  end

end
