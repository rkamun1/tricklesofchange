class SpendingsController < ApplicationController
  before_filter :authenticate
  before_filter :authorized_user, :only => [:edit, :destroy, :update]
  
  def new
    @spending = current_user.spendings.build()
    @title = "new spending"
  end

  def create
    @spending = current_user.spendings.build(params[:spending])
    if @spending.save
      flash[:success] = "Your spending has been saved!"
      redirect_to current_user
    else
      @title = "new spending"
      render 'new'
    end
  end
  
  def edit
    @spending = Spending.find(params[:id])
    @title = "edit #{@spending.spending_details}"
  end
  
  def update
    @spending = Spending.find(params[:id])
    if @spending.update_attributes(params[:spending])
      flash[:success] = "Spending updated."
      redirect_to current_user
    else
      @title = "Edit user"
      render 'edit'
    end
  end  

  def destroy
    Spending.find(params[:id]).destroy
    redirect_to root_path
  end
  
  private
    def authorized_user
      redirect_to root_path unless current_user?(Spending.find(params[:id]).user)
    end
end
