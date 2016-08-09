Airbrake.configure do |config|
 config.api_key = ENV['AIRBRAKE_API_KEY']
 config.host    = 'fg-errors.herokuapp.com'
 config.port    = 443
 config.secure  = config.port == 443
 config.environment_name = Rails.env.to_s
end
