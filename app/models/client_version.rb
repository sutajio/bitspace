class ClientVersion < ActiveRecord::Base
  
  belongs_to :client
  
  has_attached_file :download,
    :path => "clients/:client_name-:client_version.:extension",
    :storage => :s3,
    :s3_credentials => {
      :access_key_id => ENV['AMAZON_ACCESS_KEY_ID'],
      :secret_access_key => ENV['AMAZON_SECRET_ACCESS_KEY']
    },
    :url => ":s3_alias_url",
    :s3_host_alias => ENV['CDN_HOST'],
    :bucket => ENV['S3_BUCKET']
  
  validates_presence_of :version
  validates_presence_of :release_notes
  validates_presence_of :signature
  validates_uniqueness_of :version, :scope => [:client_id]
  validates_attachment_presence :download
  
  default_scope :order => 'version DESC'
  
end
