require 'rails_helper'

RSpec.describe SendEmail, type: :model do

  let(:booking) { FactoryGirl.create(:booking) }
  
  it 'sends an email' do
    expect(BookingMailer).to receive(:booking_confirmed).with('booking_id' => booking.id) {
      double(BookingMailer, deliver_now!: true)
    }
    SendEmail.run("BookingMailer", :booking_confirmed, 'booking_id' => booking.id)
  end

end
