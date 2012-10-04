class Api::NotesController < ApplicationController
  # List all notes of the paper
  #
  # URL     GET /paper/<paper_id>/notes
  def index
    begin
      # Find the paper
      paper = Paper.find(params[:paper_id])
      # Authenticate
      can_access_club?(paper.club_id)

      render :json => paper.notes
    rescue ActiveRecord::RecordNotFound
      error "Can't acess the club or the paper"
    end
  end

  # Create a note for the paper
  #
  # URL     POST /paper/<paper_id>/notes
  # PARAMS  content
  #         position
  def create
    begin
      # Find the paper
      paper = Paper.find(params[:paper_id])
      # Authenticate
      can_access_club?(paper.club_id)
      # New note
      new_note = Note.create(content: params[:content],
                             position: params[:position],
                             user_id: current_user.id,
                             paper_id: paper.id)
      if new_note
        render :json => new_note
      else
        error "Failed to create a new note"
      end
    rescue ActiveRecord::RecordNotFound
      error "Can't access the club or the paper"
    end
  end

  # Update a note
  #
  # URL     PUT /note/<note_id>
  # PARAMS  id
  #         note[content]
  #         note[position]
  def update
    begin
      # Find note
      note = Note.find(params[:id]) 
      # Authenticate
      can_access_club?(Paper.find(note.paper_id).club_id)
      
      if note.update_attributes(params[:note])
        render :json => note
      else
        error "Failed to update the note" 
      end
    rescue ActiveRecord::RecordNotFound
      error "Can't access the club or the paper"
    end
  end

  # Destroy a note
  #
  # URL     DELETE /api/notes/<id>
  # PARAMS  id
  def destroy
    begin
      # Find note
      note = Note.find(params[:id]) 
      # Authenticate
      can_access_club?(Paper.find(note.paper_id).club_id)
      
      if note.destroy
        render :json => { id: note.id }
      else
        error "Failed to destroy the note" 
      end
    rescue ActiveRecord::RecordNotFound
      error "Can't access the club or the paper"
    end
  end
end
