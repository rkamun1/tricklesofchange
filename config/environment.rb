# Load the rails application
require File.expand_path('../application', __FILE__)

ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.logger = nil
ActionMailer::Base.raise_delivery_errors = true


  ActionMailer::Base.smtp_settings = {
  :address => "smtp.gmail.com",
  :port => 587,
  :domain => "tricklesofchange.com",
  :user_name => "customerservice@tricklesofchange.com",
  :password => "d0lphins",  
  :authentication => "plain",
  :enable_starttls_auto => true,
  :tls => true

}

# Initialize the rails application
Tricklesofchange::Application.initialize!


