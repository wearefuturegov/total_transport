require 'rails_helper'

RSpec.describe SendEmail, type: :model do

  let(:booking) { FactoryGirl.create(:booking) }
  
  it 'sends an email' do
    expect(BookingMailer).to receive(:booking_confirmed).with(booking)
    SendEmail.run("Booking", booking.id)
  end

end
