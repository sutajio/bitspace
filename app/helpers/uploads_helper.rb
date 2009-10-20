require 'hmac/sha1'

module UploadsHelper
  
  def upload_key_prefix
    "uploads/#{request.remote_ip}/"
  end
  
  def s3_upload_url
    "http://#{ENV['S3_BUCKET']}.#{AWS::S3::DEFAULT_HOST}/"
  end
  
  def s3_upload_form_fields(options = {})
    options[:expiration_date] ||= 1.year.from_now.utc.strftime('%Y-%m-%dT%H:%M:%S.000Z')
    res = hidden_field_tag(:success_action_redirect, options[:success_action_redirect]) +
          hidden_field_tag(:AWSAccessKeyId, options[:AWSAccessKeyId]) +
          hidden_field_tag(:key, "#{options[:key_prefix]}${filename}") +
          hidden_field_tag(:policy, s3_upload_policy(options)) +
          hidden_field_tag(:signature, s3_upload_signature(options))
    res
  end
  
  def s3_swfupload_form_fields(options = {})
    options[:expiration_date] ||= 1.year.from_now.utc.strftime('%Y-%m-%dT%H:%M:%S.000Z')
    options[:flash] = true
    options[:success_action_status] = '201'
    { :success_action_status => options[:success_action_status],
      :AWSAccessKeyId => options[:AWSAccessKeyId],
      :key => "#{options[:key_prefix]}${filename}",
      :policy => s3_upload_policy(options),
      :signature => s3_upload_signature(options) }.to_json
  end
  
  def s3_upload_policy(options = {})
    conditions = []
    conditions << { :bucket => options[:bucket].to_s }
    conditions << ['starts-with', '$key', options[:key_prefix].to_s]
    conditions << { :success_action_redirect => options[:success_action_redirect].to_s } if options[:success_action_redirect]
    conditions << { :success_action_status => options[:success_action_status].to_s } if options[:success_action_status]
    conditions << ['starts-with', '$Filename', ''] if options[:flash]
    if options[:meta_fields].present?
      options[:meta_fields].sort.each do |meta_field|
        conditions << ['starts-with', "$#{meta_field}", '']
      end
    end
    Base64.encode64(
    "{ 
       'expiration': '#{options[:expiration_date]}',
       'conditions': #{conditions.to_json}
     }").gsub(/\n|\r/, '')
  end
  
  def s3_upload_signature(options = {})
    Base64.encode64(HMAC::SHA1.digest(options[:AWSSecretAccessKey],s3_upload_policy(options))).strip
  end
  
end
