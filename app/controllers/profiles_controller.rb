class ProfilesController < ApplicationController
  
  skip_before_filter :require_user, :except => [:follow]
  before_filter :find_user
  
  layout 'profile'
  
  def show
    @page_title = "Bitspace ◊ #{@user.login.anal_title_case}"
    if @user.collector?
      if request.path =~ /\/$/
        render :template => 'players/show', :layout => 'application'
      else
        redirect_to profile_path(@user.login, :trailing_slash => true)
      end
    else
      @releases = @user.releases.without_archived.has_tracks.paginate(
          :page => params[:page],
          :per_page => 16,
          :order => 'created_at DESC')
      @events = []
      @comments = @user.latest_comments
      render :action => 'show'
    end
  end
  
  def artists
    @page_title = "Bitspace ◊ #{@user.login.anal_title_case} / Artists"
    @artists = @user.artists.without_archived.has_releases.paginate(
        :page => params[:page],
        :per_page => 64)
  end
  
  def fans
    @page_title = "Bitspace ◊ #{@user.login.anal_title_case} / Fans"
    @subscribers = @user.subscribers.paginate(:page => params[:page], :per_page => 144)
    @followers = @user.followers.paginate(:page => params[:page], :per_page => 144)
  end
  
  def follow
    if current_user.follows?(@user)
      current_user.unfollow!(@user)
    else
      current_user.follow!(@user)
    end
    if request.xhr?
      head :ok
    else
      redirect_to :back
    end
  end
  
  def subscribe
    @new_user = User.new unless current_user
    render :action => 'subscribe', :layout => 'login'
  end
  
  def thankyou
    render :action => 'thankyou', :layout => 'login'
  end
  
  def signup
    @new_user = User.new
    render :action => 'signup', :layout => 'login'
  end
  
  def release
    @release = @user.releases.without_archived.has_tracks.find(params[:id])
    @page_title = "Bitspace ◊ #{@release.title} by #{@release.artist.name}"
  end
  
  def player
    @release = @user.releases.find(params[:id])
    render :action => 'player', :layout => false
  end
  
  def settings
    if request.put?
      if current_user.valid_password?(params[:password])
        current_user.email = params[:user][:email] if params[:user][:email].present?
        current_user.login = params[:user][:login] if params[:user][:login].present?
        current_user.password = params[:user][:password] if params[:user][:password].present?
        current_user.password_confirmation = params[:user][:password_confirmation] if params[:user][:password_confirmation].present?
        current_user.website = params[:user][:website] if params[:user][:website].present?
        current_user.biography = params[:user][:biography] if params[:user][:biography].present?
        current_user.public_profile = params[:user][:public_profile] if params[:user][:public_profile].present?
        current_user.avatar = params[:user][:avatar] if params[:user][:avatar].present?
        if current_user.save
          redirect_to profile_path(@user.login)
        else
          flash[:alert] = current_user.errors.full_messages.to_sentence
          redirect_to :back
        end
      else
        flash[:alert] = 'Invalid password'
        redirect_to :back
      end
    else
      render :action => 'settings', :layout => 'login'
    end
  end

end
