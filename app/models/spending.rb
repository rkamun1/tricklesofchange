# == Schema Information
# Schema version: 20101004013758
#
# Table name: spendings
#
#  id               :integer(4)      not null, primary key
#  spending_date    :date
#  spending_details :string(255)
#  spending_amount  :decimal(6, 2)
#  user_id          :integer(4)
#  created_at       :datetime
#  updated_at       :datetime
#

class Spending < ActiveRecord::Base
  attr_accessible :spending_date, :spending_details, :spending_amount, :created_at
  
  belongs_to :user
  twodecplaces_regex = /^([\$]?)([0-9]*\.?[0-9]{0,2})$/i
  
  validates :user_id, :presence => true
  validates :spending_date, :presence => true,
                            :date => { :after => Time.now - 2.weeks , 
                                       :before => Time.now + 1.day,
                                       :message => "date cannot be older than 2 weeks old."}

  validates :spending_details, :presence => true, :length => { :maximum => 100}
  validates :spending_amount, :presence => true,
            :format => {:with => twodecplaces_regex,
                        :message => "should be a number greater than 0; 2 decimal places optional." }     
  
  validates_numericality_of :spending_amount, 
                            :greater_than => 0,
                            :message => "should be a number greater than 0; 2 decimal places optional."
                           
                            
  default_scope :order => 'spendings.created_at DESC'
  before_save :deduct_from_bank
  after_destroy :restore_to_bank
  
  protected
  def deduct_from_bank
    user = self.user
    #if new_record?
     if spending_date == Date.today       
      new_bal = new_record? ? (user.spending_balance || user.daily_bank) - spending_amount : (user.spending_balance || user.daily_bank) + spending_amount_was - spending_amount
      
      user.update_attribute :spending_balance, new_bal if new_bal >= 0
      user.update_attribute :spending_balance, 0 if new_bal < 0
      user.update_attribute :stash, (user.stash || 0)+ new_bal if new_bal < 0
    else
      user.update_attribute :stash, new_record? ? (user.stash || 0) - spending_amount : (user.stash || 0) + spending_amount_was - spending_amount
    end
  end
  
  def restore_to_bank #TODO: Days-spending should also change
    user = self.user
    user.update_attribute :spending_balance, (user.spending_balance || 0) + spending_amount if spending_date == Date.today
    user.update_attribute :stash, (user.stash || 0) + spending_amount if spending_date != Date.today
  end
end
