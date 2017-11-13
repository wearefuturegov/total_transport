require 'rails_helper'

RSpec.describe Booking, :que, type: :model do
  
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
      email: 'me@example.com',
      pickup_landmark: stops.first.landmarks.first,
      dropoff_landmark: stops.last.landmarks.first,
    )
  }
  
  describe 'confirm!' do
    it 'sends a text message to the passenger' do
      expect { booking.confirm! }.to change { QueJob.where(job_class: 'SendSMS').count }.by(3)
      job = QueJob.find_by(job_class: 'SendSMS')
      expect(job.args[0]['to']).to eq(booking.phone_number)
    end
    
    it 'sends an email to the passenger' do
      booking.confirm!
      job = QueJob.where(job_class: 'SendEmail').find { |j| j.args[1] == 'user_confirmation'}
      expect(job.args[0]).to eq('BookingMailer')
      expect(job.args[2]).to eq('booking_id' => booking.id)
    end
    
    it 'sends an email to the supplier' do
      expect { booking.confirm! }.to change { QueJob.where(job_class: 'SendEmail').count }.by(4)
      job = QueJob.find_by(job_class: 'SendEmail')
      expect(job.args[0]).to eq('BookingMailer')
      expect(job.args[1]).to eq('booking_confirmed')
      expect(job.args[2]).to eq('booking_id' => booking.id)
    end
    
    it 'logs a booking' do
      expect { booking.confirm! }.to change { QueJob.where(job_class: 'LogBooking').count }.by(1)
      job = QueJob.find_by(job_class: 'LogBooking')
      expect(job.args[0]).to eq(booking.id)
    end
    
    it 'queues text messages' do
      expect { booking.confirm! }.to change { QueJob.where(job_class: 'SendSMS').count }.by(3)
      jobs = QueJob.where(job_class: 'SendSMS')
      first_alert = jobs.find { |j| j.args[0]['template'] == 'first_alert'}
      second_alert = jobs.find { |j| j.args[0]['template'] == 'second_alert'}
      expect(first_alert.run_at).to eq(booking.outward_trip.pickup_time - 24.hours)
      expect(second_alert.run_at).to eq(booking.outward_trip.pickup_time - 1.hours)
    end
    
    it 'queues emails' do
      expect { booking.confirm! }.to change { QueJob.where(job_class: 'SendEmail').count }.by(4)
      jobs = QueJob.where(job_class: 'SendEmail')
      first_alert = jobs.find { |j| j.args[1] == 'first_alert'}
      second_alert = jobs.find { |j| j.args[1] == 'second_alert'}
      expect(first_alert.run_at).to eq(booking.outward_trip.pickup_time - 24.hours)
      expect(second_alert.run_at).to eq(booking.outward_trip.pickup_time - 1.hours)
    end
    
    it 'sets the journey to booked' do
      booking.confirm!
      expect(booking.journey.booked).to eq(true)
    end
    
    it 'sets the booking state to booked' do
      booking.confirm!
      expect(booking.state).to eq('booked')
    end
    
    it 'does not send emails if no email is specified' do
      booking.email = nil
      booking.confirm!
      expect(QueJob.where(job_class: 'SendEmail').count).to eq(1)
    end
    
    it 'does not send text messages if no phone number is specified' do
      booking.phone_number = nil
      booking.confirm!
      expect(QueJob.where(job_class: 'SendSMS').count).to eq(0)
    end
  end
  
  context '#past?' do
    
    it 'returns false if the journey is in the future' do
      booking.journey.start_time = DateTime.now + 1.day
      expect(booking.past?).to eq(false)
    end
    
    it 'returns true if the journey is in the past' do
      booking.journey.start_time = DateTime.now - 1.day
      expect(booking.past?).to eq(true)
    end
    
  end
  
  
  context '#future?' do
    
    it 'returns true if the journey is in the future' do
      booking.journey.start_time = DateTime.now + 1.day
      expect(booking.future?).to eq(true)
    end
    
    it 'returns false if the journey is in the past' do
      booking.journey.start_time = DateTime.now - 1.day
      expect(booking.future?).to eq(false)
    end
    
  end
  
  context '#route' do
    
    it 'returns the route' do
      route = FactoryGirl.create(:route)
      booking.journey.route = route
      expect(booking.route).to eq(route)
    end
    
  end
  
  context '#price_distance' do
    
    it 'returns the distance between stops' do
      booking.pickup_stop.place.latitude = 51.7239162277052
      booking.pickup_stop.place.longitude = 0.899999141693115
      
      booking.dropoff_stop.place.latitude = 51.6275191853741
      booking.dropoff_stop.place.longitude = 0.814597606658936
      
      expect(booking.price_distance.round(1)).to eq(7.6)
    end
    
  end
  
  context 'available journeys' do
    
    let!(:route) { FactoryGirl.create(:route, stops_count: 0) }
    let!(:stops) {
      [
        FactoryGirl.create(:stop, position: 1, route: route),
        FactoryGirl.create(:stop, position: 2, route: route),
        FactoryGirl.create(:stop, position: 3, route: route),
        FactoryGirl.create(:stop, position: 4, route: route),
        FactoryGirl.create(:stop, position: 5, route: route)
      ]
    }
    
    let(:booking) { FactoryGirl.create(:booking, pickup_stop: stops[0], dropoff_stop: stops[3]) }
    let!(:journeys) {
      [
        FactoryGirl.create(:journey, route: route, start_time: "#{Date.today + 1.day}T09:00:00", reversed: false ),
        FactoryGirl.create(:journey, route: route, start_time: "#{Date.today + 2.day}T10:00:00", reversed: false ),
        FactoryGirl.create(:journey, route: route, start_time: "#{Date.today + 2.day}T09:00:00", reversed: false ),
        FactoryGirl.create(:journey, route: route, start_time: "#{Date.today + 3.day}T10:00:00", reversed: false )
      ]
    }
    
    it 'gets available_journeys' do
      FactoryGirl.create_list(:journey, 12)
      expect(booking.available_journeys).to eq(journeys)
    end
    
  end
  
  context 'pickup and dropoff times' do
    
    context '#last_dropoff_time' do
      
      it 'gets the last dropoff time for a non-return booking' do
        expect(booking.last_dropoff_time.to_s).to eq('2017-01-01 11:25:00 UTC')
      end
      
      it 'gets the last dropoff time for a return booking' do
        booking.return_journey = FactoryGirl.create(:journey, route: route, reversed: true, start_time: DateTime.parse('2017-01-01T17:00:00'))
        expect(booking.last_dropoff_time.to_s).to eq('2017-01-01 18:25:00 UTC')
      end
      
    end
    
  end
  
  context '#outward_trip' do
    
    it 'returns the correct trip' do
      expect(booking.outward_trip.journey).to eq(booking.journey)
    end
    
  end
  
  context '#return trip' do
    
    it 'returns nil by default' do
      expect(booking.return_trip).to eq(nil)
    end
    
    it 'returns a return trip' do
      booking.return_journey = FactoryGirl.create(:journey)
      expect(booking.return_trip.journey).to eq(booking.return_journey)
    end
    
  end
  
  context 'sets the journey boolean' do
    
    let(:booking) { FactoryGirl.create(:booking, state: 'booked') }
    let(:journey) { booking.journey }
    before { booking.confirm! }
    
    it 'to false if there are no more bookings' do
      booking.update_attribute :state, 'cancelled'
      journey.reload
      expect(journey.booked).to eq(false)
    end
    
    it 'to true if there still other bookings' do
      journey.bookings << FactoryGirl.create_list(:booking, 2, state: 'booked')
      journey.save
      booking.update_attribute :state, 'cancelled'
      journey.reload
      expect(journey.booked).to eq(true)
    end
    
  end
  
  describe 'number_of_adults' do
    
    let(:booking) { FactoryGirl.create(:booking) }

    it 'with only adults' do
      booking.number_of_passengers = 4
      expect(booking.number_of_adults).to eq(4)
    end
    
    it 'with children' do
      booking.number_of_passengers = 4
      booking.child_tickets = 1
      expect(booking.number_of_adults).to eq(3)
    end
    
    it 'with children and oaps' do
      booking.number_of_passengers = 4
      booking.child_tickets = 1
      booking.older_bus_passes = 1
      expect(booking.number_of_adults).to eq(2)
    end
    
    it 'with children, oaps and disabled bus passes' do
      booking.number_of_passengers = 4
      booking.child_tickets = 1
      booking.older_bus_passes = 1
      booking.disabled_bus_passes = 1
      expect(booking.number_of_adults).to eq(1)
    end
    
    it 'with children, oaps, disabled bus passes and school bus passes' do
      booking.number_of_passengers = 4
      booking.child_tickets = 1
      booking.older_bus_passes = 1
      booking.disabled_bus_passes = 1
      booking.scholar_bus_passes = 1
      expect(booking.number_of_adults).to eq(0)
    end
    
  end
  
  it 'allows pickup and dropoff landmarks to be applied' do
    pickup_landmark = FactoryGirl.create(:landmark, name: 'Pickup Landmark')
    dropoff_landmark = FactoryGirl.create(:landmark, name: 'Dropoff Landmark')
    booking.pickup_landmark = pickup_landmark
    booking.dropoff_landmark = dropoff_landmark
    booking.save
    
    expect(booking.pickup_landmark).to eq(pickup_landmark)
    expect(booking.dropoff_landmark).to eq(dropoff_landmark)
  end
  
  context 'returns data for admins' do
    
    before do
      booking.pickup_landmark.name = 'Pickup Landmark'
      booking.dropoff_landmark.name = 'Dropoff Landmark'
    end
    
    context 'without a return journey' do
      
      it 'returns a spreadsheet row' do
        expect(booking.spreadsheet_row).to eq([
          [
            'Me',
            '12345',
            'Pickup Stop',
            'Dropoff Stop',
            'Pickup Landmark',
            'Dropoff Landmark',
            '2017-01-01 10:00:00 UTC',
            nil,
            2.5
          ]
        ])
      end
       
    end
    
    context 'with a return journey' do
      
      before do
        booking.return_journey = FactoryGirl.create(:journey,
          route: route,
          start_time: DateTime.parse('2017-01-01T15:00:00'),
          reversed: true
        )
      end
      
      it 'returns a spreadsheet row' do
        expect(booking.spreadsheet_row).to eq([
          [
            'Me',
            '12345',
            'Pickup Stop',
            'Dropoff Stop',
            'Pickup Landmark',
            'Dropoff Landmark',
            '2017-01-01 10:00:00 UTC',
            '2017-01-01 15:00:00 UTC',
            3.5
          ]
        ])
      end

    end
  end
  
  describe 'runsheet csv rows' do
    
    before do
      booking.pickup_landmark.name = 'Pickup Landmark'
      booking.dropoff_landmark.name = 'Dropoff Landmark'
      booking.return_journey = FactoryGirl.create(:journey,
        route: route,
        start_time: DateTime.parse('2017-01-01T15:00:00'),
        reversed: true
      )
    end
    
    it 'returns data for the outward journey' do
      expect(booking.csv_row(booking.journey)).to eq([
        Date.parse('2017-01-01'),
        'Me',
        '12345',
        'me@example.com',
        1,
        0,
        3.5,
        'outward',
        DateTime.parse('2017-01-01 10:00:00').in_time_zone('UTC'),
        'Pickup Stop',
        'Pickup Landmark',
        DateTime.parse('2017-01-01 11:25:00').in_time_zone('UTC'),
        'Dropoff Stop',
        'Dropoff Landmark',
        booking.created_at
      ])
    end
    
    it 'returns data for the return journey' do
      expect(booking.csv_row(booking.return_journey)).to eq([
        Date.parse('2017-01-01'),
        'Me',
        '12345',
        'me@example.com',
        1,
        0,
        3.5,
        'return',
        DateTime.parse('2017-01-01 15:00:00').in_time_zone('UTC'),
        'Dropoff Stop',
        'Dropoff Landmark',
        DateTime.parse('2017-01-01 16:25:00').in_time_zone('UTC'),
        'Pickup Stop',
        'Pickup Landmark',
        booking.created_at
      ])
    end
    
  end
  
  describe 'token' do
    
    it 'generates a token' do
      expect(booking.token).to_not be_nil
    end
    
  end

  describe "pricing" do
    let(:booking) {Booking.new}
    describe "for a journey under 2 miles" do
      before {allow(booking).to receive(:price_distance).and_return(1.9) }
      describe "for a single journey" do
        before {allow(booking).to receive(:return_journey?).and_return(false) }
        it "should cost £2.50 for 1 passenger" do
          booking.number_of_passengers = 1
          expect(booking.price).to eq(2.5)
        end
        it "should cost £5.00 for 2 passengers" do
          booking.number_of_passengers = 2
          expect(booking.price).to eq(5)
        end
        it "should cost £4.00 for 2 passengers with 1 child" do
          booking.number_of_passengers = 2
          booking.child_tickets = 1
          expect(booking.price).to eq(4)
        end
        it "should cost £2.50 for 2 passengers with 1 older pass" do
          booking.number_of_passengers = 2
          booking.older_bus_passes = 1
          expect(booking.price).to eq(2.5)
        end
      end
      describe "for a return journey" do
        before {allow(booking).to receive(:return_journey?).and_return(true) }
        it "should cost £3.50 for 1 passenger" do
          booking.number_of_passengers = 1
          expect(booking.price).to eq(3.5)
        end
        it "should cost £7.00 for 2 passenger" do
          booking.number_of_passengers = 2
          expect(booking.price).to eq(7)
        end
        it "should cost £5.50 for 2 passengers with 1 child" do
          booking.number_of_passengers = 2
          booking.child_tickets = 1
          expect(booking.price).to eq(5.5)
        end
        it "should cost £3.50 for 2 passengers with 1 older pass" do
          booking.number_of_passengers = 2
          booking.older_bus_passes = 1
          expect(booking.price).to eq(3.5)
        end
      end
    end
    describe "for a journey between 2 & 5 miles" do
      before {allow(booking).to receive(:price_distance).and_return(3) }
      describe "for a single journey" do
        before {allow(booking).to receive(:return_journey?).and_return(false) }
        it "should cost £4.50 for 1 passenger" do
          booking.number_of_passengers = 1
          expect(booking.price).to eq(4.5)
        end
        it "should cost £9.00 for 2 passengers" do
          booking.number_of_passengers = 2
          expect(booking.price).to eq(9)
        end
        it "should cost £7.00 for 2 passengers with 1 child" do
          booking.number_of_passengers = 2
          booking.child_tickets = 1
          expect(booking.price).to eq(7)
        end
        it "should cost £4.50 for 2 passengers with 1 older pass" do
          booking.number_of_passengers = 2
          booking.older_bus_passes = 1
          expect(booking.price).to eq(4.5)
        end
      end
      describe "for a return journey" do
        before {allow(booking).to receive(:return_journey?).and_return(true) }
        it "should cost £6.50 for 1 passenger" do
          booking.number_of_passengers = 1
          expect(booking.price).to eq(6.5)
        end
        it "should cost £13.00 for 2 passenger" do
          booking.number_of_passengers = 2
          expect(booking.price).to eq(13)
        end
        it "should cost £10.00 for 2 passengers with 1 child" do
          booking.number_of_passengers = 2
          booking.child_tickets = 1
          expect(booking.price).to eq(10)
        end
        it "should cost £6.50 for 2 passengers with 1 older pass" do
          booking.number_of_passengers = 2
          booking.older_bus_passes = 1
          expect(booking.price).to eq(6.5)
        end
      end
    end
    describe "for a journey over 5 miles" do
      before {allow(booking).to receive(:price_distance).and_return(5.1) }
      describe "for a single journey" do
        before {allow(booking).to receive(:return_journey?).and_return(false) }
        it "should cost £5.50 for 1 passenger" do
          booking.number_of_passengers = 1
          expect(booking.price).to eq(5.5)
        end
        it "should cost £11.00 for 2 passengers" do
          booking.number_of_passengers = 2
          expect(booking.price).to eq(11)
        end
        it "should cost £8.50 for 2 passengers with 1 child" do
          booking.number_of_passengers = 2
          booking.child_tickets = 1
          expect(booking.price).to eq(8.5)
        end
        it "should cost £5.50 for 2 passengers with 1 older pass" do
          booking.number_of_passengers = 2
          booking.older_bus_passes = 1
          expect(booking.price).to eq(5.5)
        end
        it "should cost £2.50 for 2 passengers with 1 older pass and promo code of £3" do
          booking.number_of_passengers = 2
          booking.older_bus_passes = 1
          promo_code = FactoryGirl.build(:promo_code, price_deduction: 3)
          booking.promo_code = promo_code
          expect(booking.price).to eq(2.5)
        end
        it "should cost £0.00 for 2 passengers with 1 older pass and promo code of £10" do
          booking.number_of_passengers = 2
          booking.older_bus_passes = 1
          promo_code = FactoryGirl.build(:promo_code, price_deduction: 10)
          booking.promo_code = promo_code
          expect(booking.price).to eq(0)
        end
      end
      describe "for a return journey" do
        before {allow(booking).to receive(:return_journey?).and_return(true) }
        it "should cost £8.00 for 1 passenger" do
          booking.number_of_passengers = 1
          expect(booking.price).to eq(8)
        end
        it "should cost £16.00 for 2 passenger" do
          booking.number_of_passengers = 2
          expect(booking.price).to eq(16)
        end
        it "should cost £12.50 for 2 passengers with 1 child" do
          booking.number_of_passengers = 2
          booking.child_tickets = 1
          expect(booking.price).to eq(12.5)
        end
        it "should cost £8.00 for 2 passengers with 1 older pass" do
          booking.number_of_passengers = 2
          booking.older_bus_passes = 1
          expect(booking.price).to eq(8)
        end
        it "should cost £5.00 for 2 passengers with 1 older pass and promo code of £3" do
          booking.number_of_passengers = 2
          booking.older_bus_passes = 1
          promo_code = FactoryGirl.build(:promo_code, price_deduction: 3)
          booking.promo_code = promo_code
          expect(booking.price).to eq(5)
        end
        it "should cost £0.00 for 2 passengers with 1 older pass and promo code of £10" do
          booking.number_of_passengers = 2
          booking.older_bus_passes = 1
          promo_code = FactoryGirl.build(:promo_code, price_deduction: 10)
          booking.promo_code = promo_code
          expect(booking.price).to eq(0)
        end
      end
    end
  end
end
