# == Schema Information
# Schema version: 20101003204505
#
# Table name: emails
#
#  id         :integer(4)      not null, primary key
#  topic      :string(255)
#  message    :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Email < ActiveRecord::Base
  attr_accessible :name, :email, :topic, :message
end
