require 'vcr'

dotenv = Rails.root.join('.env')
filter_vars = File.exist?(dotenv) ? Dotenv::Environment.new(dotenv, false) : ENV

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.default_cassette_options = { record: :once }
  filter_vars.each do |key, value|
    c.filter_sensitive_data("<#{key}>") { value }
  end
  c.filter_sensitive_data('<ENCODED AUTH HEADER>') { Base64.encode64("#{ENV.fetch('TWILIO_ID')}:#{ENV.fetch('TWILIO_TOKEN')}").delete!("\n") }
end

RSpec.configure do |config|

  config.after(:each, gdrive: true) do |example|
    # Filter out JWT and bearer tokens from requests
    if VCR.current_cassette.recording?
      interactions = VCR.current_cassette.new_recorded_interactions
      # Remove JWT token
      interactions.first.request.body.gsub! /(?<=assertion\=).*/, '<JWT_TOKEN>'
      # Get and replace access token from body
      body = JSON.parse(interactions.first.response.body)
      access_token = body['access_token']
      body['access_token'] = '<ACCESS_TOKEN>'
      interactions.first.response.body = body.to_json
      # Replace access token in each auth request
      interactions.drop(1).each do |i|
        i.request.headers['Authorization'][0].gsub!(access_token, '<BEARER_TOKEN>')
      end
    end
  end
  
end
