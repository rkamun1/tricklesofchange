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
        flash[:success] = "Thank you, for your support."
        Notifier.invitation(@invitation, signup_url(@invitation.token)).deliver
      else
        #TODO: This flash doesn't work, check all flash'
        flash[:success] = "Thank you, we will notify you when we are ready to accept more users." 
        Notifier.invitation(@invitation, signup_url(@invitation.token)).deliver 
      end
      redirect_to root_url
    else
      render :action => 'new'
    end
  end
end
