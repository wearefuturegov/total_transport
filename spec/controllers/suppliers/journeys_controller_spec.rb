require 'rails_helper'

RSpec.describe Admin::JourneysController, type: :controller do
  login_supplier
  
  let(:journey) do
    FactoryGirl.create(:journey,
      supplier: @supplier,
      outward_bookings: FactoryGirl.create_list(:booking, 5)
    )
  end
  
  it 'sends a message to one passenger' do
    booking = journey.outward_bookings.last
    expect  {
      post :send_message, {
        id: journey.id,
        to: booking.id,
        notification_message: 'Hello!'
      }
    }.to change { FakeSMS.messages.count }.by(1)
    message = FakeSMS.messages.last
    expect(message[:to]).to eq(booking.phone_number)
    expect(message[:body]).to eq('Hello!')
  end
  
  it 'sends a message to all passengers' do
    expect  {
      post :send_message, {
        id: journey.id,
        to: 'all',
        notification_message: 'Hello!'
      }
    }.to change { FakeSMS.messages.count }.by(5)
  end


end
