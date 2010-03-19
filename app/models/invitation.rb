class Invitation < ActiveRecord::Base
  
  belongs_to :user
  
  validates_presence_of :email
  validates_format_of :email, :with => /^([a-zA-Z0-9_\-\.\+]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$/
  validates_presence_of :token
  validates_uniqueness_of :token
  
  def validate
    if user
      unless user.invitations_left.to_i > 0
        errors.add(:user, 'has no invitations left')
      end
    end
  end
  
  def decrement_invitations_left
    if user
      user.decrement!(:invitations_left)
    end
  end
  
  after_create :decrement_invitations_left
  
  def send_invitation
    InvitationMailer.deliver_invitation(self)
    self.update_attribute(:updated_at, Time.now)
  end
  
  after_create :send_invitation
  handle_asynchronously :send_invitation
  
  def generate_token
    if self.token.blank?
      self.token =
        Base64.encode64(Digest::SHA256.digest("#{Time.now}-#{rand}")).slice(-17,15).gsub('/','x').gsub('+','y')
      return true
    end
  end
  
  before_validation_on_create :generate_token
  
  def to_param
    token
  end
  
end
