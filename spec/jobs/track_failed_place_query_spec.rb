require 'rails_helper'
require 'support/vcr'

RSpec.describe TrackFailedPlaceQuery, :vcr, :webmock, type: :model do
  
  after(:each) do |example|
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
  
  it 'tracks a failed place query' do
    TrackFailedPlaceQuery.run('Place', 'from')
    spreadsheet = $google_drive_session.spreadsheet_by_key(ENV['STATS_SPREADSHEET_KEY'])
    worksheet = spreadsheet.worksheets.first
    expect(worksheet.rows.last).to eq(['Place', 'from'])
  end
  
end
