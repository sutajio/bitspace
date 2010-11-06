class Device < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :apns_token
  validates_uniqueness_of :apns_token  
end
