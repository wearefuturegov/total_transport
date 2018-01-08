require 'rails_helper'
require 'support/vcr'

RSpec.describe Metrics, type: :model do
    
  let(:subject) { Metrics.new }
  
  it 'counts all bookings' do
    FactoryBot.create_list(:booking, 1)
    FactoryBot.create_list(:booking, 2, state: 'booked', updated_at: 4.weeks.ago)
    FactoryBot.create_list(:booking, 3, state: 'booked')
    
    expect(subject.bookings_count).to eq(3)
  end
  
  it 'counts passengers' do
    FactoryBot.create_list(:booking, 1)
    FactoryBot.create_list(:booking, 2, state: 'booked', number_of_passengers: 4, updated_at: 2.weeks.ago)
    FactoryBot.create_list(:booking, 1, state: 'booked', number_of_passengers: 4)
    FactoryBot.create_list(:booking, 2, state: 'booked', number_of_passengers: 1)
    FactoryBot.create_list(:booking, 3, state: 'booked', number_of_passengers: 2)

    expect(subject.passenger_count).to eq(12)
  end
  
  it 'counts cancelled bookings' do
    FactoryBot.create_list(:booking, 1)
    FactoryBot.create_list(:booking, 2, state: 'cancelled', updated_at: 3.weeks.ago)
    FactoryBot.create_list(:booking, 3, state: 'booked')
    FactoryBot.create_list(:booking, 4, state: 'cancelled')
    
    expect(subject.cancelled_count).to eq(4)
  end
  
  it 'counts cash and card payments' do
    FactoryBot.create_list(:booking, 1, state: 'booked', payment_method: 'cash', updated_at: 2.weeks.ago)
    FactoryBot.create_list(:booking, 2, state: 'booked', payment_method: 'card', updated_at: 2.weeks.ago)
    FactoryBot.create_list(:booking, 3, state: 'booked', payment_method: 'cash')
    FactoryBot.create_list(:booking, 4, state: 'booked', payment_method: 'card')

    expect(subject.cash_payments).to eq(3)
    expect(subject.card_payments).to eq(4)
  end
  
  it 'records stats to a google spreadsheet', :vcr, :webmock, :gdrive do
    row = ['2017-09-01','12','3','5','6','2']
    expect(subject).to receive(:row) { row }
    subject.record
    spreadsheet = $google_drive_session.spreadsheet_by_key(ENV['METRICS_SPREADSHEET_KEY'])
    worksheet = spreadsheet.worksheets.first
    expect(worksheet.rows.last).to eq(row)
  end
  
end
