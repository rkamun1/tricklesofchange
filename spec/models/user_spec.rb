require 'spec_helper'

describe User do
  before(:each) do
    @attr = { :name => "Example User", 
              :email => "user@example.com",
              :password => "foobar",
              :password_confirmation => "foobar",
              :daily_bank => "20.76" 
              }
  end
  
  it "should create a new instance given valid attributes" do
    User.create!(@attr)
  end
  
  it "should require a name" do
    no_name_user = User.new(@attr.merge(:name=>""))
    no_name_user.should_not be_valid
  end
  
  it "should have a name with no more than 30 characters" do
    long_name_user = User.new(@attr.merge(:name=>"e"*31))
    long_name_user.should_not be_valid
  end
  
  it "should require email address" do
    no_email_user = User.new(@attr.merge(:email=>""))
    no_email_user.should_not be_valid
  end
  
  it "should accept valid email addresses" do
    addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    addresses.each do |address|
      valid_email_user = User.new(@attr.merge(:email => address))
      valid_email_user.should be_valid
    end
  end

  it "should reject invalid email addresses" do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    addresses.each do |address|
      invalid_email_user = User.new(@attr.merge(:email => address))
      invalid_email_user.should_not be_valid
    end
  end
  
  it "should reject duplicate email address" do
    #put user with email addy in db
    upcased_email = @attr[:email].upcase
    User.create!(@attr.merge(:email => upcased_email))
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end
  
  describe "password validations" do
    it "should require a password" do
      User.new(@attr.merge(:password => "", :password_confirmation => "")).
        should_not be_valid
    end     
    
    it "should require a matching password confirmation" do
      User.new(@attr.merge(:password_confirmation => "invalid")).
        should_not be_valid
    end

    it "should reject short passwords" do
      short = "a" * 5
      hash = @attr.merge(:password => short, :password_confirmation => short)
      User.new(hash).should_not be_valid
    end

    it "should reject long passwords" do
      long = "a" * 11
      hash = @attr.merge(:password => long, :password_confirmation => long)
      User.new(hash).should_not be_valid
    end
  end
  
  describe "daily_bank validations" do
    it "should require a daily_bank amount" do
      no_daily_bank_user = User.new(@attr.merge(:daily_bank=>""))
      no_daily_bank_user.should_not be_valid
    end
    
    it "should accept a valid daily_bank value(whole number or number and 2 decimal places)" do
      daily_banks = %w[20 20.75 1.50 20.1 1.9]
      daily_banks.each do |daily_bank|
        valid_daily_bank_amount_user = User.new(@attr.merge(:daily_bank => daily_bank))
        valid_daily_bank_amount_user.should be_valid
      end
    end
    
    it "should reject an invalid daily_bank value" do
      daily_banks = %w[20.565 20.734 .503 .433]
      daily_banks.each do |daily_bank|
        invalid_daily_bank_amount_user = User.new(@attr.merge(:daily_bank => daily_bank))
        invalid_daily_bank_amount_user.should_not be_valid
      end
    end
    
    it "should accept only numbers for daily_bank value" do
      daily_banks = %w[this that who]
      daily_banks.each do |daily_bank|
        invalid_daily_bank_user = User.new(@attr.merge(:daily_bank => daily_bank))
        invalid_daily_bank_user.should_not be_valid
      end
    end
    
    it "should not accept numbers less than 1 or greater than 999" do
      daily_banks = %w[-2 1000 0]
      daily_banks.each do |daily_bank|
        invalid_daily_bank_user = User.new(@attr.merge(:daily_bank => daily_bank))
        invalid_daily_bank_user.should_not be_valid
      end
    end
  end
  
  describe "password encryption" do  
    before(:each) do
      @user = User.create!(@attr)
    end

    it "should have an encrypted password attribute" do
      @user.should respond_to(:encrypted_password)
    end
    
    it "should set the encrypted password" do
      @user.encrypted_password.should_not be_blank
    end
  end
    
  describe "right_password? method" do
    before(:each) do
      @user = User.create!(@attr)
    end
    
    it "should be true if the passwords match" do
      @user.right_password?(@attr[:password]).should be_true
    end    

    it "should be false if the passwords don't match" do
      @user.right_password?("invalid").should be_false
    end 
  end
    
  describe "authenticate method" do
    it "should return nil on email/password mismatch" do
      wrong_password_user = User.authenticate(@attr[:email], "wrongpass")
      wrong_password_user.should be_nil
    end

    it "should return nil for an email address with no user" do
      nonexistent_user = User.authenticate("bar@foo.com", @attr[:password])
      nonexistent_user.should be_nil
    end

    it "should return the user on email/password match" do
      matching_user = User.authenticate(@attr[:email], @attr[:password])
      matching_user.should == @user
    end
  end
  
  describe "admin attribute" do

    before(:each) do
      @user = User.create!(@attr)
    end

    it "should respond to admin" do
      @user.should respond_to(:admin)
    end

    it "should not be an admin by default" do
      @user.should_not be_admin
    end

    it "should be convertible to an admin" do
      @user.toggle!(:admin)
      @user.should be_admin
    end
  end
  
  describe "account associations" do
    before(:each) do
      @user = User.create(@attr)
      @acct1 = Factory(:account, :user => @user)
      @acct2 = Factory(:account, :user => @user)
    end 
    
    it "should have an accounts attribute" do
      @user.should respond_to(:accounts)
    end
    
    it "should destroy associated accounts" do
      @user.destroy
      [@acct1, @acct2].each do |account|
        Account.find_by_id(account.id).should be_nil
      end
    end
  end
end
