require 'hmac-sha1'

module UploadsHelper
  
  def s3_upload_key_prefix
    "uploads/#{request.remote_ip}/"
  end
  
  def s3_upload_bucket
    ENV['S3_UPLOAD_BUCKET'] || ENV['S3_BUCKET']
  end
  
  def s3_upload_url
    "http://#{s3_upload_bucket}.#{AWS::S3::DEFAULT_HOST}/"
  end
  
  def s3_upload_file_param
    'file'
  end
  
  def s3_upload_params(options = {})
    options[:expiration_date] ||= s3_upload_expiration_date(1.year.from_now)
    options[:bucket] ||= s3_upload_bucket
    options[:key_prefix] ||= s3_upload_key_prefix
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
  
  def s3_upload_expiration_date(seconds_from_now)
    seconds_from_now.utc.strftime('%Y-%m-%dT%H:%M:%S.000Z')
  end
  
end
