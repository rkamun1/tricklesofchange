# == Schema Information
# Schema version: 20100822014708
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
#

#TODO: add unique username and password requirement to the database.   
#TODO: Change the authenticate to report a correct password but wrong email 

class User < ActiveRecord::Base
  attr_accessor :password
  attr_accessible :name, :email, :password, :password_confirmation, :daily_bank
  
  has_many :accounts, :dependent => :destroy
  
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
                       
  validates :daily_bank, :presence => true,
                         :format => {:with => daily_bank_regex,
                         :message => "should be a number greater than 5; 2 decimal places optional."}
                         
  validates_numericality_of :daily_bank, 
                            :greater_than => 1,
                            :less_than => 999,
                            :message => "should be a number between 1 and 999; 2 decimal places optional."
                         
  before_save :encrypt_password
  
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
  
  def feed
    # This is preliminary. See Chapter 12 for the full implementation.
    Micropost.where("user_id = ?", id)
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
                         
end
