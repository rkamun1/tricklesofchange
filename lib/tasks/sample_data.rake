require 'faker'

namespace :db do
  desc "Fill database with sample data"
  task :populate => :environment do
    Rake::Task['db:reset'].invoke
    invitation = Invitation.create!(:recipient_email => "muchira@gmail.com")
    admin = User.create!(:name => "Sir Bertly",
                   :email => "muchira@gmail.com",
                   :password => "password",
                   :password_confirmation => "password",
                   :daily_bank => 20,
                   :invitation_token => invitation.token,
                   :invitation_limit => 20,
                   :timezone => "EST",
                   :terms => 1,
                   :unit => "$")
    admin.toggle!(:admin)            
#    10.times do |n|
#      name  = Faker::Name.name
#      email = Faker::Internet.email
#      password  = "password"
#      daily_bank = 20.75
#      User.create!(:name => name,
#                   :email => email,
#                   :password => password,
#                   :password_confirmation => password,
#                   :daily_bank => daily_bank)
#    end
    
    User.all.each do |user|
#        user.accounts.create!(:details => Faker::Lorem.sentence(2), 
#                                :cost => 5 + rand(1000),
#                                :allotment => 50,
#                                :maturity_date => 1.month.from_now,
#                            :created_at => 1.day.ago)                        
#      user.spendings.create!(:spending_date => 6.days.ago, :spending_details => Faker::Lorem.sentence(2), :spending_amount => 10,:created_at => 1.day.ago) 
      
      n = 1
      k = 31
      while k >= 0                            
        p = 5 + rand(20)                    
        user.daily_stats.create!(:day => Date.today-k.day, 
                                :days_spending => p,
                                :days_stash => user.daily_stats.last.nil? ? 0:user.daily_stats.last.days_stash + 20 - p)   
        user.update_attribute(:stash,20 * n)
        n += 1
        k -= 1
      end
    end
  end
end

