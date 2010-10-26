class EmailsController < ApplicationController
  def index
    @emails = Email.all
  end
  
  def new
    @email = Email.new
  end
  
  def create
    #define the properties..
    @email = Email.new(params[:email])
    
    if !current_user.nil?
      @email.user = current_user
      @email.email = @email.user.email
      @email.name = @email.user.name
    end
      
    if @email.save
      Notifier.contact_email(@email).deliver
      flash[:notice] = "Thank you! Your email has been successfully sent."
      redirect_to root_url
    else
      render :action => 'new'
    end
  end
  
  def show
    @email = Email.find(params[:id])
  end
end
