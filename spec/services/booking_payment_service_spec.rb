require 'rails_helper'

RSpec.describe BookingPaymentService, type: :model, stripe: true do
  
  let(:booking) { FactoryBot.create(:booking) }
  let(:subject) { described_class.new(booking, @stripe_helper.generate_card_token) }
  
  context 'with a valid card' do
  
    before do
      subject.create
    end
    
    it 'sets database columns correctly' do
      expect(booking.charge_id).to_not be_nil
      expect(booking.payment_method).to eq('card')
    end
    
    it 'creates a charge' do
      charge = Stripe::Charge.retrieve(booking.charge_id)
      expect(charge.amount).to eq(booking.price_in_pence)
    end
    
    it 'creates metadata' do
      charge = Stripe::Charge.retrieve(booking.charge_id)
      expect(charge.metadata['outward_journey_url']).to eq(
        "http://example.org/admin/journeys/#{booking.outward_trip.journey.id}/bookings/#{booking.id}"
      )
    end
    
    context 'with a return trip' do
      
      before do
        booking.return_journey = FactoryBot.create(:journey,
          route: booking.route,
          start_time: DateTime.parse('2017-01-01T15:00:00'),
          reversed: true
        )
        subject.create
      end
      
      it 'creates metadata' do
        charge = Stripe::Charge.retrieve(booking.charge_id)
        expect(charge.metadata['outward_journey_url']).to eq(
          "http://example.org/admin/journeys/#{booking.outward_trip.journey.id}/bookings/#{booking.id}"
        )
        expect(charge.metadata['return_journey_url']).to eq(
          "http://example.org/admin/journeys/#{booking.return_trip.journey.id}/bookings/#{booking.id}"
        )
      end
      
    end
    
  end
  
  context 'with an invalid card' do
    
    before do
      StripeMock.prepare_card_error(:card_declined)
    end
    
    it 'returns false' do
      expect(subject.create).to eq(false)
    end
    
    it 'generates an error' do
      subject.create
      expect(subject.error).to_not be_nil
    end
    
  end
  
end
