if Rails.env.test?
  Twilio.configure do |config|
    config.account_sid = ENV['TWILIO_TEST_ID']
    config.auth_token = ENV['TWILIO_TEST_TOKEN']
  end
  TWILIO_PHONE_NUMBER = '+15005550006'
else
  Twilio.configure do |config|
    config.account_sid = ENV['TWILIO_ID']
    config.auth_token = ENV['TWILIO_TOKEN']
  end
  TWILIO_PHONE_NUMBER = '+441173252034'
end
