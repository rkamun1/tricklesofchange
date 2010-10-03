class Email < ActiveRecord::Base
  attr_accessible :name, :email, :topic, :message
end
