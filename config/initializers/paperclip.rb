Paperclip.interpolates :unix_timestamp do |attachment, style|
  attachment.instance_read(:updated_at).to_i
end
