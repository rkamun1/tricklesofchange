class InvitationsController < ApplicationController
  def new
    @invitation = Invitation.new
  end
  
  def create
    @invitation = Invitation.new(params[:invitation])
    @invitation.sender = current_user
    @invitation.sent_at = Time.now
      
    if @invitation.save
      if signed_in?
        Notifier.invitation(@invitation, signup_url(@invitation.token)).deliver
        flash[:success] = "Thank you, for your support."
      else
        Notifier.new_request(@invitation, signup_url(@invitation.token)).deliver
        flash[:success] = "Thank you for signing up. Please check your email (check spam too) for your invitation."  
      end
      redirect_to root_url
    else
      render :action => 'new'
    end
  end

  def join
    @invitation = Invitation.new
  end
end
