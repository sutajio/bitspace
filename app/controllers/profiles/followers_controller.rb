class Profiles::FollowersController < Profiles::ProfilesController

  def index
    @followers = @user.followers.paginate(:page => params[:page])
  end

end
