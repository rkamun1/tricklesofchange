class Notifier < ActionMailer::Base  
  layout 'notifier'
  def forgotten_password(recipient, new_pass)
    title = "Your password has been reset"
    @user = recipient
    @password = new_pass
    
    mail(:to => recipient.email, :subject => "Your password has been reset.")  
  end
end
