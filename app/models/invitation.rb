# == Schema Information
# Schema version: 20100921213456
#
# Table name: invitations
#
#  id              :integer(4)      not null, primary key
#  sender_id       :integer(4)
#  recipient_email :string(255)
#  token           :string(255)
#  sent_at         :datetime
#  created_at      :datetime
#  updated_at      :datetime
#

class Invitation < ActiveRecord::Base
  attr_accessible :sender_id, :recipient_email, :token, :sent_at
  
  belongs_to :sender, :class_name => 'User'
  has_one :recipient, :class_name => 'User'
  
  validates_presence_of :recipient_email
  validate :recipient_is_not_registered
  validate :sender_has_invitations, :if => :sender

  before_create :generate_token
  before_create :decrement_sender_count, :if => :sender

  private

  def recipient_is_not_registered
    errors.add :recipient_email, 'is already registered' if User.find_by_email(recipient_email)
  end

  def sender_has_invitations
    unless sender.invitation_limit > 0
      errors.add_to_base 'You have reached your limit of invitations to send.'
    end
  end

  def generate_token
    self.token = Digest::SHA1.hexdigest([Time.now, rand].join)
  end

  def decrement_sender_count
    sender.decrement! :invitation_limit
  end
end