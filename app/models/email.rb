# == Schema Information
# Schema version: 20101026024751
#
# Table name: emails
#
#  id         :integer(4)      not null, primary key
#  topic      :string(255)
#  message    :string(255)
#  created_at :datetime
#  updated_at :datetime
#  user_id    :integer(4)
#  email      :string(255)
#  name       :string(255)



class Email < ActiveRecord::Base
  attr_accessible :name, :email, :topic, :message

  belongs_to :user

  validates_presence_of :name
  validates_presence_of :topic
  validates_presence_of :message

  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :email,:presence => true, 
                   :format => {:with => email_regex}

end
