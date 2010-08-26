require 'spec_helper'

describe Account do
  before(:each) do
    @user = Factory(:user)
    @attr = {:details => "Pair of Vesace jeans",
             :cost => "200",
             :allotment => "20"}
  end
  
  it "should create a new instance given valid attributes" do
    @user.accounts.create!(@attr)
  end
  
  describe "user associations" do
    before(:each) do
      @account = @user.accounts.create(@attr)
    end

    it "should have a user attribute" do
      @account.should respond_to(:user)
    end

    it "should have the right associated user" do
      @account.user_id.should == @user.id
      @account.user.should == @user
    end
  end
  
  describe "validations" do
    describe "failure" do
      it "should require a user_id" do
        Account.new(@attr).should_not be_valid
      end
      
      it "should require nonblank details" do
        @user.accounts.build(@attr.merge(:details => " ")).should_not be_valid
      end
      
      it "should require nonblank cost" do
        @user.accounts.build(@attr.merge(:cost => " ")).should_not be_valid
      end
      
      it "should require nonblank allotment" do
        @user.accounts.build(@attr.merge(:allotment => " ")).should_not be_valid
      end
      
      it "should reject long details" do
        @user.accounts.build(@attr.merge(:details => "a" * 81)).should_not be_valid
      end
      
      it "should reject short details" do
        @user.accounts.build(@attr.merge(:details => "a" * 3)).should_not be_valid
      end
      
      it "should reject non-numeric cost" do
        @user.accounts.build(@attr.merge(:cost => "test")).should_not be_valid
      end
      
      it "should reject a cost less than 5 dollars" do
        costs = %w[1 2 3 4 -1 -2 -3 -80]
        costs.each do |cost|
          invalid_cost = @user.accounts.build(@attr.merge(:cost => cost))
          invalid_cost.should_not be_valid
        end
      end
      
      it "should reject cost that is not curency like" do
        costs = %w[1.389 9.9090]
        costs.each do |cost|
          invalid_cost = @user.accounts.build(@attr.merge(:cost => cost))
          invalid_cost.should_not be_valid
        end
      end
      
      it "should reject non-numeric allotment" do
        @user.accounts.build(@attr.merge(:allotment => "test")).should_not be_valid
      end
      
      #TODO: make sure this shit works.....whhhaaattt??
#      it "should reject allotment that is not to 2 or less decimal places" do
#        allotments = %w[1.389 9.919]
#        allotments.each do |allotment|
#          invalid_allotment = @user.accounts.build(@attr.merge(:allotment => allotment))
#          invalid_allotment.should_not be_valid
#        end
#      end
      
      it "should reject allotment less than 1 or greater than 100" do
        allotments = %w[0 101]
        allotments.each do |allotment|
          invalid_allotment = @user.accounts.build(@attr.merge(:allotment => allotment))
          invalid_allotment.should_not be_valid
        end
      end
      
    end
    
    describe "success" do
      it "should accept cost that is curency like; over 5" do
        costs = %w[10 10.50 5.1 5]
        costs.each do |cost|
          invalid_cost = @user.accounts.build(@attr.merge(:cost => cost))
          invalid_cost.should be_valid
        end
      end
      
      it "should accept allotment between 1 and 100" do
        allotments = %w[1 25.25 50.50 100]
        allotments.each do |allotment|
          invalid_allotment = @user.accounts.build(@attr.merge(:allotment => allotment))
          invalid_allotment.should be_valid
        end
      end
    end
  end
end
