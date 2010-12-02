class Notifier < ActionMailer::Base  
  layout 'notifier'
  
  default :bcc => 'info@tricklesofchange.com',
          :from => 'customerservice@tricklesofchange.com',
          :reply_to => 'customerservice@tricklesofchange.com'
  

  #send a forgotten password
  def forgotten_password(user, password)
    attachments.inline['newheader.png'] = File.read(Rails.root.join('public/images/newheader.png'))
    @user = user
    @password = password
    title = "Your password has been reset"
    mail(:to => @user.email, :subject => "Your password has been reset.")  
  end
  
  #send an invitaion
  def invitation invitation, signup_url
    attachments.inline['newheader.png'] = #File.read(Rails.root.join('public/images/newheader.png'))
    @invitation = invitation 
    @signup_url = signup_url
    mail(:to => @invitation.recipient_email, 
         :subject => "You have been invited to Tricklesofchange.")
  end

  #a new request notification to admin
  def new_request invitation, signup_url
    attachments.inline['newheader.png'] = #File.read(Rails.root.join('public/images/newheader.png'))
    @invitation = invitation 
    @signup_url = signup_url
    mail(:to => @invitation.recipient_email, 
         :subject => "Welcome to Tricklesofchange.")
  end

  #send the inviter and the system a joined notification
  def joined invitation 
    attachments.inline['newheader.png'] = File.read(Rails.root.join('public/images/newheader.png'))
    @invitation = invitation
    if !@invitation.sender.nil?
      mail(:to => @invitation.sender.email,
           :subject => "Your invitation has been accepted.")
    else
      mail(:subject => "Your invitation has been accepted.")
    end       
  end

  #emails sent from the contact me page
  def contact_email email
    attachments.inline['newheader.png'] = File.read(Rails.root.join('public/images/newheader.png'))
    @email = email
    mail(:reply_to => @email.email,
         :to => @email.email,
         :bcc => "customerservice@tricklesofchange.com",
         :subject => @email.topic)  
  end
end
