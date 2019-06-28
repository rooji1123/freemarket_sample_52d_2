require 'carrierwave/storage/abstract'
require 'carrierwave/storage/file'
require 'carrierwave/storage/fog'

CarrierWave.configure do |config|
  access = Rails.application.credentials.aws_access_key_id
  secret = Rails.application.credentials.secret_key_base
  if Rails.env.production?
    config.storage = :fog
    config.fog_provider = 'fog/aws'
    config.fog_credentials = {
      provider: 'AWS',
      aws_access_key_id: access,
      aws_secret_acccess_key: secret,
      region: 'ap-northeast-1'
    }
  else
    config.storage :file
    config.enable_processing = false if Rails.env.test?
  end

  config.fog_directory = 'freemarket52d'
  config.asset_host = 'https://s3.ap-northeast-1.amazonaws.com/freemarket52d'
end