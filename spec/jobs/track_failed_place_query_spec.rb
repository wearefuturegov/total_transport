require 'rails_helper'
require 'support/vcr'

RSpec.describe TrackFailedPlaceQuery, :vcr, :webmock, :gdrive, type: :model do
  
  it 'tracks a failed place query' do
    TrackFailedPlaceQuery.run('origin', 'destination', '2017-01-01T00:00:00+00:00')
    spreadsheet = $google_drive_session.spreadsheet_by_key(ENV['STATS_SPREADSHEET_KEY'])
    worksheet = spreadsheet.worksheets.first
    expect(worksheet.rows.last).to eq(['origin', 'destination', '2017-01-01T00:00:00+00:00'])
  end
  
  it 'tracks a failed place query without a destination' do
    TrackFailedPlaceQuery.run('origin', nil, '2017-01-01T00:00:00+00:00')
    spreadsheet = $google_drive_session.spreadsheet_by_key(ENV['STATS_SPREADSHEET_KEY'])
    worksheet = spreadsheet.worksheets.first
    expect(worksheet.rows.last).to eq(['origin', '', '2017-01-01T00:00:00+00:00'])
  end
  
end
