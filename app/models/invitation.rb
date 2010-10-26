# == Schema Information
# Schema version: 20101002175215
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
#  used            :boolean(1)
#

class Invitation < ActiveRecord::Base
  attr_accessible :sender_id, :recipient_email, :token, :sent_at
  
  belongs_to :sender, :class_name => 'User'
  has_one :recipient, :class_name => 'User'
  
  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :recipient_email,:presence => true, 
                   :format => {:with => email_regex}
  validate :recipient_is_not_registered
  validate :has_a_previous_invite
  validate :sender_has_invitations, :if => :sender

  before_create :generate_token
  before_create :decrement_sender_count, :if => :sender

#TODO: add uniqueness
  private

  def recipient_is_not_registered
    errors.add :recipient_email, 'is already registered OR' if User.find_by_email(recipient_email)
  end

  def has_a_previous_invite
      errors.add :recipient_email, 'already has a pending invite!!' if Invitation.find_by_recipient_email(recipient_email) 
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
