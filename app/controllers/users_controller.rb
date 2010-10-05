class UsersController < ApplicationController
  before_filter :authenticate, :only => [:index, :edit, :show, :update]
  before_filter :correct_user, :only => [:edit, :show, :update]
  before_filter :admin_user,   :only => [:destroy, :index]
  before_filter :already_signed_in, :only => [:new]

#TODO: a user should be able to delete thier own account

  def new
    @title = "Sign Up"
    #@user = User.new
    @user = User.new(:invitation_token => params[:invitation_token])
    @user.email = @user.invitation.recipient_email if !@user.invitation.nil?
  end
  
  def index
    @title = "All users"
    @users = User.paginate(:page => params[:page])
  end

  def show 
    @user = User.find(params[:id])
    @accounts = @user.accounts
    @spendings = @user.spendings
    @title = @user.name
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      flash[:success] = "Welcome!"
      #housekeping
      @user.invitation.toggle :used
      Notifier.joined(@user.invitation).deliver and @user.invitation.
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
      Time.zone = @user.timezone
      flash[:success] = "Profile updated."
      redirect_to @user
    else
      @title = "Edit user"
      render 'edit'
    end
  end  
  
  def forgot_password
    if request.post?
      unless params[:email].blank?
        user = User.find_by_email(params[:email])
        if user
          user.forgot_password!
          flash[:notice] = "A new password has been sent to you. Please check your email."
          redirect_to signin_path
        else
          flash[:error] = "We could not find a user with that email address."
        end
      end
    end
  end

  
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User destroyed."
    redirect_to root_path
  end
  
  def reset
    @user = current_user
    @user.reset @user
    redirect_to root_path
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
