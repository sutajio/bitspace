class CommentsController < ApplicationController

  def create
    @comment = Comment.create!(params[:comment].merge(:user => current_user))
    if request.xhr?
      head :ok
    else
      redirect_to :back
    end
  end

end
