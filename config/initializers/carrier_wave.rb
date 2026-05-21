if Rails.env.production?
  CarrierWave.configure do |config|
    config.fog_credentials = {
      provider: 'AWS',
      region: ENV.fetch('S3_REGION', nil),
      aws_access_key_id: ENV.fetch('S3_ACCESS_KEY', nil),
      aws_secret_access_key: ENV.fetch('S3_SECRET_KEY', nil)
    }
    config.fog_directory = ENV.fetch('S3_BUCKET', nil)
  end
end
