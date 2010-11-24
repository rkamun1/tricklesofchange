class AccountsController < ApplicationController
  before_filter :authenticate
  before_filter :authorized_user, :only => [:edit, :destroy, :update]
  
  def new
    @account = current_user.accounts.build()
    @title = "new account"
    respond_to do |format|  
     format.html  
     format.js
    end  
  end

  def create
    @account = current_user.accounts.build(params[:account])
    if @account.save
      flash[:success] = "Your account has been saved!"
      respond_to do |format|  
       format.html{redirect_to current_user}
       format.js
      end  
    else
      @title = "new account"
      respond_to do |format|  
       format.html{render 'new'}
       format.js{render 'new'}
      end  
    end
  end
  
  def edit
    @account = Account.find(params[:id])
    @title = "edit #{@account.details}"
    respond_to do |format|  
     format.html  
     format.js{render 'new'}
    end  
  end
  
  def update
    @account = Account.find(params[:id])
    if @account.update_attributes(params[:account])
      flash[:success] = "Account updated."
      respond_to do |format|  
       format.html{redirect_to current_user}
       format.js
      end  
    else
       @title = "edit account"
      respond_to do |format|  
       format.html{render 'edit'}
       format.js{render 'new'}
      end  
    end
  end  

  def destroy
    @account = Account.find(params[:id])
    @account.destroy
    respond_to do |format|  
       format.html{redirect_to root_path}
       format.js 
    end  
  end
  
  private
    def authorized_user
      redirect_to root_path unless current_user?(Account.find(params[:id]).user)
    end

end
