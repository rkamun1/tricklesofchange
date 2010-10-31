# == Schema Information
# Schema version: 20101004013758
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
#  stash              :decimal(6, 2)   default(0.0)
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
  has_many :emails

  
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
  
  def self.daily_job
    User.all.each do |user|
      #insert config.timezone
      Time.zone = user.timezone
      puts Time.now
      if Time.now.hour == Time.now.hour #TODO: change to 0 - this makes it run at the midnight hour.
      	puts "in midnight"
        user.insert_latest_daily_stat

				#if the user has entered any spending values that day
				if !(days_entered_spendings = user.spendings.where({ :created_at => (Time.now.midnight - 1.day)..Time.now.midnight})).empty?          
puts days_entered_spendings.inspect
          user.update_daily_stats days_entered_spendings #with any spending information.                  
		    end
			end
		end
	end

  def update_daily_stats days_entered_spendings
    first_date = days_entered_spendings.minimum(:spending_date).to_date
    last_date = days_entered_spendings.maximum(:spending_date).to_date
        
    #TODO: What if the person spends more than his days spending. Does a neg get distributed? Or 0?
    (first_date..last_date).each do |dte|   
      new_day_spending = days_entered_spendings.where(:spending_date => dte).sum(:spending_amount) if !days_entered_spendings.where(:spending_date => dte).empty?

      if !new_day_spending.nil?
        old_days_spending = daily_stats.where(:day => dte).first.days_spending

        #perform the distribution
        distro_difference_total = 0
        accounts.where('maturity_date >= ?', dte).where("Date(created_at) <= Date(?)",dte).each do |account|
          "new_day_spending = #{new_day_spending.to_s}"
          account.update_attribute(:accrued, ((account.accrued || 0) - distro_difference = (new_day_spending * account.allotment)/100))
puts "distro_difference = #{distro_difference}"
          distro_difference_total += distro_difference
	      end
puts "distro_difference_total = #{distro_difference_total}"
        #get the difference in contribution to the stash.
        days_stash_difference = new_day_spending - distro_difference_total

puts "stash difference #{days_stash_difference}"

        days_stat = daily_stats.where(:day=>dte).first
        days_stat.update_attributes(:days_spending=> (days_stat.days_spending + new_day_spending),:days_stash=> (days_stat.days_stash - days_stash_difference)) if !days_stat.nil?


        #get all daily stats greater than this dte and subtract the difference from
        daily_stats.where('day > ?', dte).each do |days_stat|
          #days_stat.update_attribute(:days_stash,(days_stat.days_stash - days_stash_difference))
        end
		    update_attribute(:stash, daily_stats.last.days_stash)
      end
    end 
  end

  def insert_latest_daily_stat
    puts "Inserting lastest stat"
    #Default case: update the deets assuming that the user spent nothing that day
    total_distro = 0
    #perform the distribution
    accounts.each do |account|
	    if account.maturity_date.future? || account.maturity_date.today?
	      account.update_attribute(:accrued, ((account.accrued || 0) + distributed_amount = ((daily_bank * account.allotment)/100)))
	      total_distro += distributed_amount
	    end
    end    
    update_attribute(:stash, (stash || 0) + (daily_bank - total_distro)) 
    update_attribute(:spending_balance, daily_bank)
    daily_stats.create(attr={:day=>Time.zone.now.yesterday, :days_spending => 0, :days_stash => stash}) 
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
