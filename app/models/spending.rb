# == Schema Information
# Schema version: 20101026024751
#
# Table name: spendings
#
#  id               :integer(4)      not null, primary key
#  spending_date    :datetime
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
                            :date => { :before => Time.now,
                                       :message => "the spending date cannot be newer than todays's date"}

  validate :join_date

  validates :spending_details, :presence => true, :length => { :maximum => 100}
  validates :spending_amount, :presence => true,
            :format => {:with => twodecplaces_regex,
                        :message => "should be a number greater than 0; 2 decimal places optional." }     
  
  validates_numericality_of :spending_amount, 
                            :greater_than => 0,
                            :message => "should be a number greater than 0; 2 decimal places optional."
                           
                            
  default_scope :order => 'spendings.created_at DESC'
  before_save :deduct_from_bank, :after_spending_distribution
  after_destroy :restore_to_bank, :after_deleted_spending
  
  protected

#new record
  def deduct_from_bank
    user = self.user
    #if new_record?
     if spending_date == Date.today       
      new_bal = new_record? ? (user.spending_balance || user.daily_bank) - spending_amount : (user.spending_balance || user.daily_bank) + spending_amount_was - spending_amount
      
      user.update_attribute :spending_balance, new_bal

      #user.update_attribute :stash, new_record? ? (user.stash || 0) - spending_amount : (user.stash || 0) + spending_amount_was - spending_amount
    end
  end

  def after_spending_distribution
    user = self.user
    #puts "spending= #{spending_amount} on #{spending_date}"

    spending = new_record? ? spending_amount : (spending_amount - spending_amount_was)
    #perform the distribution
    distro_total = 0
    user.accounts.where('Date(maturity_date) >= ?', spending_date).where("Date(created_at) <= ?",spending_date).each do |account|
      account.update_attribute(:accrued, ((account.accrued || 0) - distro = ((spending) * account.allotment)/100))
      distro_total += distro
    end
    
    #get the difference in contribution to the stash.
    days_stash_difference = (spending) + distro_total

#puts "distro_total = #{distro_total}"
    days_stat = user.daily_stats.where('date(day) = ?', spending_date).first
    days_stat.update_attributes(:days_spending=> days_stat.days_spending + spending, :days_stash=> (days_stat.days_stash - days_stash_difference)) if !days_stat.nil?

    #get all daily stats greater than this dte and subtract the difference from
    user.daily_stats.where('date(day) > ?', spending_date).each do |days_stat|
      days_stat.update_attribute(:days_stash,(days_stat.days_stash - days_stash_difference))
    end
    user.update_attribute(:stash, user.daily_stats.last.days_stash)
  end

#Deletions  
  def restore_to_bank #TODO: Days-spending should also change
    user = self.user
    user.update_attribute :spending_balance, (user.spending_balance || 0) + spending_amount if spending_date == Date.today
    user.update_attribute :stash, (user.stash || 0) + spending_amount if spending_date != Date.today
  end
  
  def after_deleted_spending
    #perform the distribution
    distro_total = 0
    user.accounts.where('Date(maturity_date) >= ?', spending_date).where("Date(created_at) <= ?",spending_date).each do |account|
      account.update_attribute(:accrued, ((account.accrued || 0) + distro = (spending_amount * account.allotment)/100))
      distro_total += distro
    end
    
    #get the difference in contribution to the stash.
    days_stash_difference = spending_amount + distro_total
    #puts "distro_total = #{distro_total}"
    days_stat = user.daily_stats.where('date(day) = ?', spending_date).first
    days_stat.update_attributes(:days_spending=> days_stat.days_spending - spending_amount, :days_stash=> (days_stat.days_stash + days_stash_difference)) if !days_stat.nil?

    #get all daily stats greater than this dte and subtract the difference from
    user.daily_stats.where('date(day) > ?', spending_date).each do |days_stat|
      days_stat.update_attribute(:days_stash,(days_stat.days_stash + days_stash_difference))
    end
    user.update_attribute(:stash, user.daily_stats.last.days_stash)
  end
  
  def join_date
    if (spending_date.to_date < self.user.created_at.to_date - 1.day) 
      errors.add(:spending_date,"the spending date cannot be older than the date you joined tricklesofchange.com.")
    end
  end
end 
