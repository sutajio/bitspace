class InvitationRequest < ActiveRecord::Base
  validates_presence_of :email
  validates_format_of :email, :with => /^([a-zA-Z0-9_\-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$/
  validates_uniqueness_of :email

  def send_notification
    InvitationRequestMailer.deliver_notification(self)
  end

  after_create :send_notification
  handle_asynchronously :send_notification

end
