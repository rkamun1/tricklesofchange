class Notifier < ActionMailer::Base  
  layout 'notifier'
  
  default :bcc => 'muchira@gmail.com',
          :from => 'no-reply@tricklesofchange.com'

  #send a forgotten password
  def forgotten_password(user, password)
    @user = user
    @password = password
    title = "Your password has been reset"
    mail(:to => @user.email, :subject => "Your password has been reset.")  
  end
  
  #send an invitaion
  def invitation invitation, signup_url
    @invitation = invitation 
    puts "this is the signup url #{signup_url}"
    @signup_url = signup_url
    mail(:to => @invitation.recipient_email, 
         :subject => "You have been invited to tricklesofchange.com.")
  end
  
  #send the inviter and the system a joined notification
  def joined invitation 
    @invitation = invitation
    mail(:to => @invitation.sender.email || ""
         :subject => "Your invitation has been accepted.")
  end
end
