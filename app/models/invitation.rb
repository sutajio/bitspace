class Invitation < ActiveRecord::Base
  
  belongs_to :user
  
  validates_presence_of :email
  validates_format_of :email, :with => /^([a-zA-Z0-9_\-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$/
  validates_presence_of :token
  #validates_uniqueness_of :token
  
  def send_invitation!
    InvitationMailer.deliver_invitation(self)
    self.update_attribute(:updated_at, Time.now)
  end
  
  after_create :send_invitation!
  handle_asynchronously :send_invitation! if Rails.env.production?
  
  def generate_token
    unless self.token.present?
      self.token =
        Base64.encode64(Digest::SHA256.digest("#{Time.now}-#{rand}")).slice(-17,15)
    end
  end
  
  def to_param
    token
  end
end
