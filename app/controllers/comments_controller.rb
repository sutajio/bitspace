class CommentsController < ApplicationController

  def create
    @comment = Comment.create!(params[:comment].merge(:user => current_user))
    head :ok
  end

end
