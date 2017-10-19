require "rails_helper"

RSpec.describe BookingMailer, type: :mailer do
  
  describe 'booking_confirmed' do
    
    let(:stops) {
      [
        FactoryGirl.create(:stop, minutes_from_last_stop: nil, position: 1, place: FactoryGirl.create(:place, name: 'Pickup Stop')),
        FactoryGirl.create(:stop, minutes_from_last_stop: 40, position: 2),
        FactoryGirl.create(:stop, minutes_from_last_stop: 20, position: 3),
        FactoryGirl.create(:stop, minutes_from_last_stop: 10, position: 4),
        FactoryGirl.create(:stop, minutes_from_last_stop: 15, position: 5, place: FactoryGirl.create(:place, name: 'Dropoff Stop'))
      ]
    }
    let(:route) { FactoryGirl.create(:route, stops: stops) }
    let(:journey) { FactoryGirl.create(:journey, route: route, start_time: DateTime.parse('2017-01-01T10:00:00')) }
    let(:booking) {
      FactoryGirl.create(:booking,
        journey: journey,
        pickup_stop: stops.first,
        dropoff_stop: stops.last,
        passenger_name: 'Me',
        phone_number: '12345',
        pickup_landmark: stops.first.landmarks.first,
        dropoff_landmark: stops.last.landmarks.first,
      )
    }
    
    let(:mail) { BookingMailer.booking_confirmed(booking) }
    let(:body) { Nokogiri::HTML(mail.body.encoded).text.squish }
    
    before do
      booking.pickup_landmark.name = 'Pickup Landmark'
      booking.dropoff_landmark.name = 'Dropoff Landmark'
    end
    
    it 'renders the headers' do
      expect(mail.subject).to eq('A new booking has been confirmed')
      expect(mail.to).to eq([ENV['RIDE_ADMIN_EMAIL']])
      expect(mail.from).to eq([ENV['RIDE_ADMIN_EMAIL']])
    end
    
    it 'renders the body' do
      expect(body).to match(/Name: Me/)
      expect(body).to match(/Phone Number: 12345/)
      expect(body).to match(/Travelling at 10:00am on Sunday, 1 Jan/)
      expect(body).to match(/From: Pickup Stop/)
      expect(body).to match(/To: Dropoff Stop/)
      expect(body).to match(/Pickup Landmark: Pickup Landmark/)
      expect(body).to match(/Dropoff Landmark: Dropoff Landmark/)
      expect(body).to match(/The passenger will need to pay £2.50 to the driver/)
      expect(body).to match(/This is a single journey only/)
    end
    
    it 'shows a return journey' do
      booking.return_journey = FactoryGirl.create(:journey,
        route: route,
        start_time: DateTime.parse('2017-01-01T15:00:00'),
        reversed: true
      )

      expect(body).to match(/Return Journey/)
      expect(body).to match(/Travelling at 3:00pm on Sunday, 1 Jan/)
      expect(body).to match(/From: Dropoff Stop/)
      expect(body).to match(/To: Pickup Stop/)
      expect(body).to match(/Pickup Landmark: Dropoff Landmark/)
      expect(body).to match(/Dropoff Landmark: Pickup Landmark/)
      expect(body).to match(/The passenger will need to pay £3.50 to the driver/)
      expect(body).to_not match(/This is a single journey only/)
    end
    
  end
  
end
