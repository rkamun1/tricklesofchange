# == Schema Information
# Schema version: 20101112050442
#
# Table name: faqs
#
#  id         :integer(4)      not null, primary key
#  question   :string(255)
#  answer     :text
#  created_at :datetime
#  updated_at :datetime
#

class Faq < ActiveRecord::Base
  attr_accessible :question, :answer
end
