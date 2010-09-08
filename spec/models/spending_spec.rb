require 'spec_helper'

describe Spending do
  before(:each) do
    @user = Factory(:user)
    @attr = {
      :spending_date => Time.now,
      :spending_details => "The ish I spent my money on",
      :spending_amount => "5.00"
    }
  end
  
  it "should create a new instance given valid attributes" do
    @user.spendings.create!(@attr)
  end
  
  describe "user associations" do

    before(:each) do
      @spendings = @user.spendings.create(@attr)
    end

    it "should have a user attribute" do
      @spendings.should respond_to(:user)
    end

    it "should have the right associated user" do
      @spendings.user_id.should == @user.id
      @spendings.user.should == @user
    end
  end
  
  describe "validations" do

    it "should require a user id" do
      Spending.new(@attr).should_not be_valid
    end

    it "should require nonblank spending_details" do
      @user.spendings.build(:spending_details => "  ").should_not be_valid
    end

    it "should reject long spending_details" do
      @user.spendings.build(:spending_details => "a" * 101).should_not be_valid
    end
  end
end
