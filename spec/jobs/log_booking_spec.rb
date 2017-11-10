require 'rails_helper'
require 'support/vcr'

RSpec.describe LogBooking, :vcr, :webmock, :gdrive, type: :model do
  
  let(:booking) { FactoryGirl.create(:booking) }

  it 'logs a booking' do
    LogBooking.run(booking.id)
    spreadsheet = $google_drive_session.spreadsheet_by_key(ENV['BOOKINGS_SPREADSHEET_KEY'])
    worksheet = spreadsheet.worksheets.first
    expect(worksheet.rows.last).to eq(booking.spreadsheet_row[0].map { |c| c.to_s })
  end

end
