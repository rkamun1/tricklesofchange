module SessionsHelper
  
  def sign_in(user)
    cookies.permanent.signed[:remember_token] = [user.id, user.salt]
    Time.zone = user.timezone
    current_user = user
  end
  
  def current_user=(user)
    @current_user = user
  end
  
  def current_user
    @current_user ||= user_from_remember_token
  end
  
  def signed_in?
    !current_user.nil?
    Time.zone = current_user.timezone
  end
  
  def current_user?(user)
    user == current_user
  end

  def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
  end
    
  def admin?
    current_user.admin?
  end 
  
  def already_signed_in
    redirect_to current_user if signed_in?
  end
  
  def authenticate
    deny_access unless signed_in?
  end
  
  def deny_access
    store_location
    flash[:notice] = "Please sign in to access that page."
    redirect_to signin_path
  end

  def store_location
    session[:return_to] = request.fullpath
  end

  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    clear_return_to
  end
  
  def clear_return_to
    session[:return_to] = nil
  end

  def sign_out
    cookies.delete(:remember_token)
    self.current_user = nil
  end

  private
    def user_from_remember_token
      User.authenticate_with_salt(*remember_token)
    end

    def remember_token
      cookies.signed[:remember_token] || [nil, nil]
    end
    
end
