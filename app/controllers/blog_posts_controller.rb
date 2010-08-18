class BlogPostsController < ApplicationController
  layout 'site'
  skip_before_filter :require_user
  skip_before_filter :require_chrome_frame_if_ie
  before_filter :authenticate, :except => [:index, :show]
  
  def index
    @page_title = 'The Product Blog, New Features, Tips, Previews, Discussion - Bitspace'
    @posts = BlogPost.published.paginate(:page => params[:page])
    respond_to do |with|
      with.html
      with.atom
    end
  end
  
  def show
    @post = BlogPost.published.find_by_year_and_month_and_slug(params[:year], params[:month], params[:slug]) or raise ActiveRecord::RecordNotFound
    @page_title = @post.title
  end
  
  def preview
    @post = BlogPost.published.find(params[:id])
  end
  
  def new
    @post = BlogPost.new
  end
  
  def create
    @post = BlogPost.new(params[:blog_post])
    @post.save!
    if @post.published?
      redirect_to blog_path
    else
      redirect_to admin_blog_path
    end
  rescue ActiveRecord::RecordInvalid => e
    render :action => 'new'
  end
  
  def edit
    @post = BlogPost.find(params[:id])
  end
  
  def update
    @post = BlogPost.find(params[:id])
    @post.update_attributes!(params[:blog_post])
    if @post.published?
      redirect_to blog_path
    else
      redirect_to admin_blog_path
    end
  rescue ActiveRecord::RecordInvalid => e
    render :action => 'edit'
  end
  
  def destroy
    @post = BlogPost.find(params[:id])
    @post.destroy
    redirect_to blog_path
  end
  
  def admin
    @post = BlogPost.new
    render :action => 'new'
  end
  
  protected

    def authenticate
      authenticate_or_request_with_http_basic do |username, password|
        username == 'admin' && password == ENV['ADMIN_PASSWORD']
      end
    end

end
