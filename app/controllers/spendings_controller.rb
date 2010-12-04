class SpendingsController < ApplicationController
  before_filter :authenticate
  before_filter :authorized_user, :only => [:edit, :destroy, :update]
  
  def new
    @spending = current_user.spendings.build()
    @title = "new spending"
    respond_to do |format|  
     format.html  
     format.js
    end  
  end

  def create
    @spending = current_user.spendings.build(params[:spending])
    @user = @spending.user
    if @spending.save
      flash[:success] = "Your spending has been saved!"
      respond_to do |format|  
       format.html{redirect_to current_user}
       format.js
      end 
    else
      @title = "new spending"
      respond_to do |format|  
       format.html{render 'new'}
       format.js{render 'new'}
      end  
    end
  end
  
  def edit
    @spending = Spending.find(params[:id])
    @title = "edit #{@spending.spending_details}"
    respond_to do |format|  
     format.html  
     format.js{render 'new'}
    end  
  end
  
  def update
    @spending = Spending.find(params[:id])
    @user = @spending.user
    if @spending.update_attributes(params[:spending])
      flash[:success] = "Spending updated."
      respond_to do |format|  
       format.html{redirect_to current_user}
       format.js
      end 
    else
      @title = "Edit user"
      respond_to do |format|  
       format.html{render 'edit'}
       format.js{render 'new'}
      end  
    end
  end  

  def destroy
    @spending = Spending.find(params[:id])
    @user = @spending.user
    @spending.destroy
    respond_to do |format|  
       format.html{redirect_to root_path}
       format.js 
    end  
  end
  
  private
    def authorized_user
      redirect_to root_path unless current_user?(Spending.find(params[:id]).user)
    end
end
