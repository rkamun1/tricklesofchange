require 'faker'

namespace :db do
  desc "Fill database with sample data"
  task :populate => :environment do
    Rake::Task['db:reset'].invoke
    admin = User.create!(:name => "Example User",
                 :email => "example@railstutorial.org",
                 :password => "foobar",
                 :password_confirmation => "foobar",
                 :daily_bank => 20)
    admin.toggle!(:admin)            
    10.times do |n|
      name  = Faker::Name.name
      email = Faker::Internet.email
      password  = "password"
      daily_bank = 20.75
      User.create!(:name => name,
                   :email => email,
                   :password => password,
                   :password_confirmation => password,
                   :daily_bank => daily_bank)
    end
    
    User.all.each do |user|
      5.times do
        user.accounts.create!(:details => Faker::Lorem.sentence(2), 
                                :cost => 5 + rand(1000),
                                :allotment => 1 + rand(20))                                
      end
      
      65.times do |n|                                                  
        user.daily_stats.create!(:day => Date.today-n.day, 
                                :days_spending => 1 + rand(20))                                                      
      end
    end
  end
end

