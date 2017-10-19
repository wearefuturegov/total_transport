require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.default_cassette_options = { record: :once }
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
