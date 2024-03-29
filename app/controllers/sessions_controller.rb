class SessionsController < ApplicationController
  before_filter :already_signed_in, :only => [:new]
  
 def new
    @title = "Welcome"
  end

  def create    #create a session consists of signing in
    user = User.authenticate(params[:session][:email],
                           params[:session][:password])
    if user.nil?
      flash.now[:error] = "Invalid email/password combination."
      @title = "Sign in"
      render 'new'
    else
      sign_in user
      redirect_back_or user
    end
  end

  def destroy
    sign_out
    redirect_to root_path
  end
end
