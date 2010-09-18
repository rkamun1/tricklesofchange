# == Schema Information
# Schema version: 20100917180617
#
# Table name: daily_stats
#
#  id            :integer(4)      not null, primary key
#  day           :date
#  days_spending :decimal(6, 2)
#  user_id       :integer(4)
#  created_at    :datetime
#  updated_at    :datetime
#

class DailyStat < ActiveRecord::Base
    belongs_to :user   
end
