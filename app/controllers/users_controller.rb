class UsersController < ApplicationController
  before_filter :authenticate, :only => [:index, :edit, :update]
  before_filter :correct_user, :only => [:edit, :update]
  before_filter :admin_user,   :only => :destroy

  def new
    @title = "Sign Up"
    @user = User.new
  end
  
  def index
    @title = "All users"
    @users = User.paginate(:page => params[:page])
  end

  def show 
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(:page => params[:page])
    @title = @user.name
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to the Chirp!"
      redirect_to @user 
    else
      @title = "Sign Up"
      render 'new'
    end
  end
  
  def edit
    @title = "Edit user"
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated."
      redirect_to @user
    else
      @title = "Edit user"
      render 'edit'
    end
  end  
  
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User destroyed."
    redirect_to users_path
  end
  
  def feed
    # This is preliminary. See Chapter 12 for the full implementation.
    Micropost.where("user_id = ?", id)
  end

  private    
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end
    
    def admin_user
      if current_user.nil?
        redirect_to(signin_path)
      else if !current_user.admin?
        redirect_to(root_path)
      end
    end
  end
end
