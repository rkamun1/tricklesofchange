# == Schema Information
# Schema version: 20100822014708
#
# Table name: accounts
#
#  id         :integer(4)      not null, primary key
#  details    :string(255)
#  cost       :decimal(6, 2)
#  allotment  :integer(4)
#  accrued    :decimal(6, 2)
#  user_id    :integer(4)
#  created_at :datetime
#  updated_at :datetime
#
#TODO: add a dealine to this model

class Account < ActiveRecord::Base
  attr_accessible :details, :cost, :allotment
  
  belongs_to :user
  
  twodecplaces_regex = /^([\$]?)([0-9]*\.?[0-9]{0,2})$/i
  
  validates :user_id, :presence => true
  
  validates :details, :presence => true,
                      :length => {:within => 4..80}
                      
  validates :cost, :presence => true,
                   :format => {:with => twodecplaces_regex,
                   :message => "should be a number greater than 5; 2 decimal places optional." }            
                   
  validates :allotment, :presence => true,
                   :format => {:with => twodecplaces_regex,
                   :message => "should be a number between 1 and 100; 2 decimal places optional." }          
  
  validate :allotment_is_100, :if => :validate_allotment?
  
  validates_numericality_of :cost, 
                            :greater_than_or_equal_to => 5,
                            :message => "should be a number greater than 5; 2 decimal places optional."
                            
  validates_numericality_of :allotment, 
                            :greater_than => 0,
                            :less_than_or_equal_to => 100,
                            :message => "should be a number between 1 and 100; 2 decimal places optional."                       

#TODO: Make sure that all the account.alloments <= 100%.
  protected
  def allotment_is_100
    other_acccount_allotments = Account.where(:user_id => user_id).where('id != ?', :id).sum(:allotment)
    if allotment + other_acccount_allotments > 100
      errors.add(:allotment, "adds up to more than 100. The maximum allotment for this account is #{100 - other_acccount_allotments}")
    end
  end

  def validate_allotment?
    new_record? || allotment_changed?
  end
end
