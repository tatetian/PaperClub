class Debug::PapersController < ApplicationController
  def show
    @paper = Paper.find(params[:paper_id])
    @paper_uuid = @paper.doc_hash 
  end
end
