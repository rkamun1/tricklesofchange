class EmailsController < ApplicationController
  def index
    @emails = Email.all
  end
  
  def new
    @email = Email.new
  end
  
  def create
    @email = Email.new(params[:email])
    if @email.save
      flash[:notice] = "Successfully created email."
      redirect_to @email
    else
      render :action => 'new'
    end
  end
  
  def show
    @email = Email.find(params[:id])
  end
end
