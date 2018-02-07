require "rails_helper"

RSpec.describe BookingMailer, type: :mailer do
  
  let(:stops) {
    [
      FactoryBot.create(:stop, minutes_from_last_stop: nil, position: 1,
        place: FactoryBot.create(:place, name: 'Pickup Stop'),
        landmarks: FactoryBot.create_list(:landmark, 1, name: 'Pickup Landmark')
      ),
      FactoryBot.create(:stop, minutes_from_last_stop: 40, position: 2),
      FactoryBot.create(:stop, minutes_from_last_stop: 20, position: 3),
      FactoryBot.create(:stop, minutes_from_last_stop: 10, position: 4),
      FactoryBot.create(:stop, minutes_from_last_stop: 15, position: 5,
        place: FactoryBot.create(:place, name: 'Dropoff Stop'),
        landmarks: FactoryBot.create_list(:landmark, 1, name: 'Pickup Landmark')
      )
    ]
  }
  let(:route) { FactoryBot.create(:route, stops: stops) }
  let(:team) { FactoryBot.create(:team, email: 'team@example.com') }
  let(:journey) { FactoryBot.create(:journey, route: route, start_time: DateTime.parse('2017-01-01T10:00:00'), team: team) }
  let(:booking) {
    FactoryBot.create(:booking,
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
        expect(mail.subject).to eq("A new booking has been confirmed (ref: RIDE#{booking.id.to_s.rjust(5, '0')})")
        expect(mail.to).to eq(['team@example.com'])
        expect(mail.from).to eq([ENV['RIDE_ADMIN_EMAIL']])
      end
      
      it 'renders the body' do
        expect(body).to match(/A new booking has been confirmed/)
        expect(body).to match(/Name: Me/)
        expect(body).to match(/Mobile Number: 12345/)
        expect(body).to match(/Travelling at 10:00am on Sunday, 1 Jan/)
        expect(body).to match(/From: Pickup Stop/)
        expect(body).to match(/To: Dropoff Stop/)
        expect(body).to match(/Pickup place: Pickup Landmark/)
        expect(body).to match(/Dropoff place: Dropoff Landmark/)
        expect(body).to match(/Amount: £12.00/)
        expect(body).to match(/Payment method: cash/)
        expect(body).to match(/This is a single journey/)
      end
      
      context 'with card payment' do
        
        before do
          booking.payment_method = 'card'
          booking.save
        end
        
        it 'renders the body' do
          expect(body).to match(/Payment method: Prepaid by card/)
        end
        
      end
      
    end
    
    describe '#booking_cancelled' do
      
      let(:mail) { BookingMailer.booking_cancelled('booking_id' => booking.id) }
      
      it 'renders the headers' do
        expect(mail.subject).to eq('Booking cancelled')
        expect(mail.to).to eq(['team@example.com'])
        expect(mail.from).to eq([ENV['RIDE_ADMIN_EMAIL']])
      end
      
      it 'renders the body' do
        expect(body).to match(/A booking has been cancelled/)
        expect(body).to match(/Name: Me/)
        expect(body).to match(/Mobile Number: 12345/)
        expect(body).to match(/Travelling at 10:00am on Sunday, 1 Jan/)
        expect(body).to match(/From: Pickup Stop/)
        expect(body).to match(/To: Dropoff Stop/)
        expect(body).to match(/Pickup place: Pickup Landmark/)
        expect(body).to match(/Dropoff place: Dropoff Landmark/)
        expect(body).to match(/This is a single journey/)
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
        expect(body).to match(/Your Ride booking from Pickup Stop to Dropoff Stop for 1 passenger is confirmed/)
        expect(body).to match(/Your vehicle will collect you from Pickup Landmark, Pickup Stop/)
        expect(body).to match(/on Sunday, 1 Jan/)
        expect(body).to match(/between 9:50am – 10:10am/)
      end
      
    end
    
    describe '#user_cancellation' do
      
      let(:mail) { BookingMailer.user_cancellation('booking_id' => booking.id) }
      
      it 'renders the headers' do
        expect(mail.subject).to eq('Ride booking cancellation')
        expect(mail.to).to eq([booking.email])
        expect(mail.from).to eq([ENV['RIDE_ADMIN_EMAIL']])
      end
      
      it 'renders the body' do
        expect(body).to match(/Hello Me/)
        expect(body).to match(/Sunday, 1 Jan at 9:50am – 10:10am from Pickup Stop, Pickup Landmark has been cancelled/)
      end
      
    end
    
    describe '#feedback' do
      
      let(:mail) { BookingMailer.feedback('booking_id' => booking.id) }
      
      it 'renders the headers' do
        expect(mail.subject).to eq('We hope you enjoyed your Ride')
        expect(mail.to).to eq([booking.email])
        expect(mail.from).to eq([ENV['RIDE_ADMIN_EMAIL']])
      end
      
      it 'renders the body' do
        expect(body).to match(/Hello Me/)
        expect(body).to match(/We hope you enjoyed your Ride. To help us improve the service, please share your feedback/)
      end
      
    end
    
  end
  
  describe 'with a return journey' do
    before do
      booking.return_journey = FactoryBot.create(:journey,
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
        expect(body).to match(/Pickup place: Dropoff Landmark/)
        expect(body).to match(/Dropoff place: Pickup Landmark/)
        expect(body).to match(/Amount: £18.00/)
        expect(body).to match(/This is a return journey/)
      end
      
    end
    
    describe '#user_confirmation' do
      
      let(:mail) { BookingMailer.user_confirmation('booking_id' => booking.id) }
      
      it 'renders the body' do
        expect(body).to match(/Your return journey is from Dropoff Landmark, Dropoff Stop/)
        expect(body).to match(/on Sunday, 1 Jan/)
        expect(body).to match(/between 2:50pm – 3:10pm/)
      end
      
    end
    
  end
  
end
