require 'paperclip'

Paperclip.interpolates :unix_timestamp do |attachment, style|
  attachment.instance_read(:updated_at).to_i
end

Paperclip.interpolates :client_name do |attachment, style|
  attachment.instance.client.slug
end

Paperclip.interpolates :client_version do |attachment, style|
  attachment.instance.version
end
