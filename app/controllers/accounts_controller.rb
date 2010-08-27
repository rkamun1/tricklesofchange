class AccountsController < ApplicationController
  before_filter :authenticate
  before_filter :authorized_user, :only => [:edit, :destroy, :update]
  
  def new
    @account = current_user.accounts.build()
    @title = "new account"
  end

  def create
    @account = current_user.accounts.build(params[:account])
    if @account.save
      flash[:success] = "Your account has been saved!"
      redirect_to current_user
    else
      @title = "new account"
      render 'new'
    end
  end
  
  def edit
    @account = Account.find(params[:id])
    @title = "edit #{@account.details}"
  end
  
  def update
    if @account.update_attributes(params[:account])
      flash[:success] = "Account updated."
      redirect_to current_user
    else
      @title = "Edit user"
      render 'edit'
    end
  end  

  def destroy
    Account.find(params[:id]).destroy
    redirect_to root_path
  end
  
  private

    def authorized_user
      redirect_to root_path unless current_user?(Account.find(params[:id]).user)
    end

end
