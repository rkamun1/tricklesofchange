# == Schema Information
# Schema version: 20101004013758
#
# Table name: faqs
#
#  id         :integer(4)      not null, primary key
#  question   :string(255)
#  answer     :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Faq < ActiveRecord::Base
  attr_accessible :question, :answer
end
