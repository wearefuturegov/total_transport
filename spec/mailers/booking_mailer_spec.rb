require "rails_helper"

RSpec.describe BookingMailer, type: :mailer do
  
  let(:stops) {
    [
      FactoryGirl.create(:stop, minutes_from_last_stop: nil, position: 1,
        place: FactoryGirl.create(:place, name: 'Pickup Stop'),
        landmarks: FactoryGirl.create_list(:landmark, 1, name: 'Pickup Landmark')
      ),
      FactoryGirl.create(:stop, minutes_from_last_stop: 40, position: 2),
      FactoryGirl.create(:stop, minutes_from_last_stop: 20, position: 3),
      FactoryGirl.create(:stop, minutes_from_last_stop: 10, position: 4),
      FactoryGirl.create(:stop, minutes_from_last_stop: 15, position: 5,
        place: FactoryGirl.create(:place, name: 'Dropoff Stop'),
        landmarks: FactoryGirl.create_list(:landmark, 1, name: 'Pickup Landmark')
      )
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
      email: 'hello@example.com'
    )
  }
  
  let(:body) { Nokogiri::HTML(mail.body.encoded).text.squish }
  
  before do
    booking.pickup_landmark.name = 'Pickup Landmark'
    booking.pickup_landmark.save
    booking.dropoff_landmark.name = 'Dropoff Landmark'
    booking.dropoff_landmark.save
  end
  
  describe 'with a single journey' do
    
    describe '#booking_confirmed' do
      
      let(:mail) { BookingMailer.booking_confirmed('booking_id' => booking.id) }
      
      it 'renders the headers' do
        expect(mail.subject).to eq('A new booking has been confirmed')
        expect(mail.to).to eq([booking.journey.supplier.email])
        expect(mail.from).to eq([ENV['RIDE_ADMIN_EMAIL']])
      end
      
      it 'renders the body' do
        expect(body).to match(/A new booking has been confirmed/)
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
      
    end
    
    describe '#booking_cancelled' do
      
      let(:mail) { BookingMailer.booking_cancelled('booking_id' => booking.id) }
      
      it 'renders the headers' do
        expect(mail.subject).to eq('Booking cancelled')
        expect(mail.to).to eq([booking.journey.supplier.email])
        expect(mail.from).to eq([ENV['RIDE_ADMIN_EMAIL']])
      end
      
      it 'renders the body' do
        expect(body).to match(/A booking has been cancelled/)
        expect(body).to match(/Name: Me/)
        expect(body).to match(/Phone Number: 12345/)
        expect(body).to match(/Travelling at 10:00am on Sunday, 1 Jan/)
        expect(body).to match(/From: Pickup Stop/)
        expect(body).to match(/To: Dropoff Stop/)
        expect(body).to match(/Pickup Landmark: Pickup Landmark/)
        expect(body).to match(/Dropoff Landmark: Dropoff Landmark/)
        expect(body).to match(/This is a single journey only/)
      end
      
    end
    
    describe '#user_confirmation' do
      
      let(:mail) { BookingMailer.user_confirmation('booking_id' => booking.id) }
      
      it 'renders the headers' do
        expect(mail.subject).to eq('Your Ride booking confirmation')
        expect(mail.to).to eq([booking.email])
        expect(mail.from).to eq([ENV['RIDE_ADMIN_EMAIL']])
      end
      
      it 'renders the body' do
        expect(body).to match(/Hello Me/)
        expect(body).to match(/Your Ride booking from Pickup Stop to Dropoff Stop is confirmed/)
        expect(body).to match(/Your approved local driver will pick you up from Pickup Landmark, Pickup Stop/)
        expect(body).to match(/on Sunday, 1 Jan/)
        expect(body).to match(/between 9:50am – 10:10am/)
      end
      
    end
    
  end
  
  describe 'with a return journey' do
    before do
      booking.return_journey = FactoryGirl.create(:journey,
        route: route,
        start_time: DateTime.parse('2017-01-01T15:00:00'),
        reversed: true
      )
      booking.save
    end
    
    describe '#booking_confirmed' do
      
      let(:mail) { BookingMailer.booking_confirmed('booking_id' => booking.id) }
      
      it 'renders the body' do
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
    
    describe '#user_confirmation' do
      
      let(:mail) { BookingMailer.user_confirmation('booking_id' => booking.id) }
      
      it 'renders the body' do
        expect(body).to match(/Your return ride will be from Dropoff Landmark, Dropoff Stop/)
        expect(body).to match(/on Sunday, 1 Jan/)
        expect(body).to match(/between 2:50pm – 3:10pm/)
      end
      
    end
    
  end
  
  describe '#first_alert' do
    
    let(:mail) { BookingMailer.first_alert('booking_id' => booking.id) }
    
    it 'renders the headers' do
      expect(mail.subject).to eq('Your Ride booking is tomorrow')
      expect(mail.to).to eq([booking.email])
      expect(mail.from).to eq([ENV['RIDE_ADMIN_EMAIL']])
    end
    
    it 'renders the body' do
      expect(body).to match(/You’ll be picked up from Pickup Landmark, Pickup Stop/)
      expect(body).to match(/on Sunday, 1 Jan/)
      expect(body).to match(/between 9:50am – 10:10am/)
    end
    
  end
  
  describe '#second_alert' do
    
    let(:mail) { BookingMailer.second_alert('booking_id' => booking.id) }
    
    it 'renders the headers' do
      expect(mail.subject).to eq('Your Ride is on it’s way.')
      expect(mail.to).to eq([booking.email])
      expect(mail.from).to eq([ENV['RIDE_ADMIN_EMAIL']])
    end
    
    it 'renders the body' do
      expect(body).to match(/Your pickup point is Pickup Landmark, Pickup Stop/)
      expect(body).to match(/between 9:50am – 10:10am/)
      expect(body).to match(/The cost of your journey is £2.50/)
    end
    
  end
  
  
end
