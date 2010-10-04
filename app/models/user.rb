# == Schema Information
# Schema version: 20101003204505
#
# Table name: users
#
#  id                 :integer(4)      not null, primary key
#  name               :string(255)
#  email              :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  encrypted_password :string(255)
#  salt               :string(255)
#  admin              :boolean(1)
#  daily_bank         :decimal(6, 2)
#  stash              :decimal(6, 2)
#  spending_balance   :decimal(6, 2)
#  invitation_id      :integer(4)
#  invitation_limit   :integer(4)
#  timezone           :string(255)
#  unit               :string(255)
#

#TODO: add unique username requirement to the DATABASE as  opposed to model.   
#TODO: Change the authenticate to report a correct password but wrong email 
#TODO: Add timezone and currency type

class User < ActiveRecord::Base
  attr_accessor :password
  attr_accessible :name, :email, :password, :password_confirmation, :daily_bank, :invitation_token, :timezone, :unit

  
  belongs_to :invitation
  has_many :accounts, :dependent => :destroy
  has_many :spendings, :dependent => :destroy  
  has_many :daily_stats, :dependent => :destroy
  has_many :sent_inivitations, :class_name => 'Invitation', :foreign_key => 'sender_id'

  
  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  daily_bank_regex = /^([\$]?)([0-9]*\.?[0-9]{0,2})$/i

  validates :name, :presence => true,
                   :length => {:maximum => 30}
                   
  validates :email,:presence => true, 
                   :format => {:with => email_regex},
                   :uniqueness => {:case_sensitive => false}
                   
  validates :password, :presence => true,
                       :confirmation => true,
                       :length       => { :within => 6..10 }
                       
  validates :timezone, :presence => true                     
                       
  validates :daily_bank, :presence => true,
                         :format => {:with => daily_bank_regex}
                         
  validates_numericality_of :daily_bank, 
                            :greater_than => 1,
                            :less_than => 999,
                            :message => "should be a number between 1 and 999; 2 decimal places optional."
                            
  validates_presence_of :invitation_id, :message => "is required"       
  #TODO: validates_uniqueness_of :invitation_id                 
                         
  before_create :set_invitation_limit
  before_save :encrypt_password, :if => :valid_password? 
  
  def valid_password?
    !password.nil?
  end
  
  def invitation_token
    invitation.token if invitation
  end

  def invitation_token=(token)
    self.invitation = Invitation.find_by_token(token)
  end

  
  # Return true if the user's password matches the submitted password.
  def right_password?(submitted_password)
    encrypted_password == encrypt(submitted_password)
  end
  
  def self.authenticate(email, submitted_password)
    user = find_by_email(email)
    return nil  if user.nil?
    return user if user.right_password?(submitted_password)
  end
  
  def self.authenticate_with_salt(id, cookie_salt)
    user = find_by_id(id)
    (user && user.salt == cookie_salt) ? user : nil
  end
    
  def forgot_password!
    self.password = self.password_confirmation = User.random_string(10)
    self.save
    Notifier.forgotten_password(self,password).deliver
  end
  
  def spending_on(date)
      daily_stats.where(:day=>date).first.days_spending.to_f if !daily_stats.where(:day=>date).first.nil?
  end
  
  def stash_on(date)
      daily_stats.where(:day=>date).first.days_stash.to_f if !daily_stats.where(:day=>date).first.nil?
  end
  
  def reset(user)
    user.update_attribute(:stash, 0)
    user.accounts.each do |account|  
      account.update_attribute(:accrued, 0)
    end
  end
  
  def self.daily_job # <------TODO:if I get another task, move this to a daily_tasks file
    
    User.all.each do |user|
      #get the user bank
      total_distro = 0
      
      Time.zone = user.timezone
      
      if Time.zone.now.hour == Time.zone.now.midnight.hour
        puts "in here and the time is #{Time.zone.now}"
        if (user.spending_balance || user.daily_bank) >= 0
          distributed_amount = 0
          #perform the distribution
          user.accounts.each do |account|
            if account.maturity_date > Date.today
              account.update_attribute(:accrued, ((account.accrued || 0) + distributed_amount = (((user.spending_balance || user.daily_bank) * account.allotment)/100)))
              total_distro += distributed_amount
              puts "total = #{total_distro}"
            end
          end      
          
          #update the stash
          user.update_attribute(:stash, (user.stash || 0) + (user.spending_balance || user.daily_bank) - total_distro) 
          
          #collect the stats        
          user.daily_stats.create(attr={:day=>Date.yesterday, :days_spending=>(user.daily_bank - (user.spending_balance || user.daily_bank)), :days_stash=>(user.stash || 0)})        
          #reset the value        
          user.update_attribute(:spending_balance, user.daily_bank) 
        end  
      end
    end
  end
  

  private
    def encrypt_password
      self.salt = make_salt if new_record?
      self.encrypted_password = encrypt(password)
    end

    def encrypt(string)
      secure_hash("#{salt}--#{string}")
    end
    
    def make_salt
      secure_hash("#{Time.now.utc}--#{password}")
    end    
    
    def secure_hash(string)
      Digest::SHA2.hexdigest(string)
    end
    
    def self.random_string(len)
     #generate a random password consisting of strings and digits
     chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
     newpass = ""
     1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
     return newpass
   end
   
   def set_invitation_limit
     self.invitation_limit = 5
   end
                
end
