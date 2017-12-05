require 'rails_helper'

RSpec.describe Booking, :que, type: :model do
  
  let(:stops) {
    [
      FactoryBot.create(:stop, minutes_from_last_stop: nil, position: 1, place: FactoryBot.create(:place, name: 'Pickup Stop')),
      FactoryBot.create(:stop, minutes_from_last_stop: 40, position: 2),
      FactoryBot.create(:stop, minutes_from_last_stop: 20, position: 3),
      FactoryBot.create(:stop, minutes_from_last_stop: 10, position: 4),
      FactoryBot.create(:stop, minutes_from_last_stop: 15, position: 5, place: FactoryBot.create(:place, name: 'Dropoff Stop'))
    ]
  }
  let(:route) { FactoryBot.create(:route, stops: stops) }
  let(:journey) { FactoryBot.create(:journey, route: route, start_time: DateTime.parse('2017-01-01T10:00:00')) }
  let(:booking) {
    FactoryBot.create(:booking,
      journey: journey,
      pickup_stop: stops.first,
      dropoff_stop: stops.last,
      passenger_name: 'Me',
      phone_number: '12345',
      email: 'me@example.com',
      pickup_landmark: stops.first.landmarks.first,
      dropoff_landmark: stops.last.landmarks.first,
      special_requirements: 'Wheelchair'
    )
  }
  
  describe 'confirm!' do
    it 'sends a text message to the passenger' do
      expect { booking.confirm! }.to change { QueJob.where(job_class: 'SendSMS').count }.by(4)
      job = QueJob.find_by(job_class: 'SendSMS')
      expect(job.args[0]['to']).to eq(booking.phone_number)
    end
    
    it 'sends an email to the passenger' do
      booking.confirm!
      job = QueJob.where(job_class: 'SendEmail').find { |j| j.args[1] == 'user_confirmation'}
      expect(job.args[0]).to eq('BookingMailer')
      expect(job.args[2]).to eq('booking_id' => booking.id)
    end
    
    it 'queues up a survey link' do
      booking.confirm!
      job = QueJob.where(job_class: 'SendEmail').find { |j| j.args[1] == 'feedback'}
      expect(job.args[0]).to eq('BookingMailer')
      expect(job.args[2]).to eq('booking_id' => booking.id)
    end
    
    it 'sends an email to the supplier' do
      expect { booking.confirm! }.to change { QueJob.where(job_class: 'SendEmail').count }.by(3)
      job = QueJob.find_by(job_class: 'SendEmail')
      expect(job.args[0]).to eq('BookingMailer')
      expect(job.args[1]).to eq('booking_confirmed')
      expect(job.args[2]).to eq('booking_id' => booking.id)
    end
    
    it 'queues text messages' do
      expect { booking.confirm! }.to change { QueJob.where(job_class: 'SendSMS').count }.by(4)
      jobs = QueJob.where(job_class: 'SendSMS')
      first_alert = jobs.find { |j| j.args[0]['template'] == 'first_alert'}
      second_alert = jobs.find { |j| j.args[0]['template'] == 'second_alert'}
      post_survey = jobs.find { |j| j.args[0]['template'] == 'post_survey'}
      expect(first_alert.run_at).to eq(booking.outward_trip.pickup_time - 24.hours)
      expect(second_alert.run_at).to eq(booking.outward_trip.pickup_time - 1.hours)
      expect(post_survey.run_at).to eq(booking.outward_trip.dropoff_time + 30.minutes)
    end
    
    it 'queues a text message for the return journey' do
      booking.return_journey = FactoryBot.create(:journey)
      expect { booking.confirm! }.to change { QueJob.where(job_class: 'SendSMS').count }.by(5)
      jobs = QueJob.where(job_class: 'SendSMS')
      alert = jobs.select { |j| j.args[0]['template'] == 'second_alert'}.last
      post_survey = jobs.find { |j| j.args[0]['template'] == 'post_survey'}
      expect(alert.run_at).to eq(booking.return_trip.pickup_time - 1.hours)
      expect(post_survey.run_at).to eq(booking.return_trip.dropoff_time + 30.minutes)
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
      route = FactoryBot.create(:route)
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
    
    let!(:route) { FactoryBot.create(:route, stops_count: 0) }
    let!(:stops) {
      [
        FactoryBot.create(:stop, position: 1, route: route),
        FactoryBot.create(:stop, position: 2, route: route),
        FactoryBot.create(:stop, position: 3, route: route),
        FactoryBot.create(:stop, position: 4, route: route),
        FactoryBot.create(:stop, position: 5, route: route)
      ]
    }
    
    let(:booking) { FactoryBot.create(:booking, pickup_stop: stops[0], dropoff_stop: stops[3]) }
    let!(:journeys) {
      [
        FactoryBot.create(:journey, route: route, start_time: "#{Date.today + 1.day}T09:00:00", reversed: false ),
        FactoryBot.create(:journey, route: route, start_time: "#{Date.today + 2.day}T10:00:00", reversed: false ),
        FactoryBot.create(:journey, route: route, start_time: "#{Date.today + 2.day}T09:00:00", reversed: false ),
        FactoryBot.create(:journey, route: route, start_time: "#{Date.today + 3.day}T10:00:00", reversed: false )
      ]
    }
    
    it 'gets available_journeys' do
      FactoryBot.create_list(:journey, 12)
      expect(booking.available_journeys).to match_array(journeys)
    end
    
    it 'ignores full journeys' do
      full_journey = journeys[0]
      FactoryBot.create_list(:booking, full_journey.vehicle.seats, journey: full_journey, state: 'booked')
      expect(booking.available_journeys).to_not include(full_journey)
    end
    
  end
  
  context 'pickup and dropoff times' do
    
    context '#last_dropoff_time' do
      
      it 'gets the last dropoff time for a non-return booking' do
        expect(booking.last_dropoff_time.to_s).to eq('2017-01-01 11:25:00 UTC')
      end
      
      it 'gets the last dropoff time for a return booking' do
        booking.return_journey = FactoryBot.create(:journey, route: route, reversed: true, start_time: DateTime.parse('2017-01-01T17:00:00'))
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
      booking.return_journey = FactoryBot.create(:journey)
      expect(booking.return_trip.journey).to eq(booking.return_journey)
    end
    
  end
  
  context 'cancelling booking' do
    let(:booking) { FactoryBot.create(:booking, state: 'booked') }
    before { booking.confirm! }
    
    context 'sets the journey boolean' do
      let(:journey) { booking.journey }
      
      it 'to false if there are no more bookings' do
        booking.update_attribute :state, 'cancelled'
        journey.reload
        expect(journey.booked).to eq(false)
      end
      
      it 'to true if there still other bookings' do
        journey.bookings << FactoryBot.create_list(:booking, 2, state: 'booked')
        journey.save
        booking.update_attribute :state, 'cancelled'
        journey.reload
        expect(journey.booked).to eq(true)
      end
    end
    
    context 'removes all the alerts', :que do
      
      before do
        booking.email = 'someone@example.com'
        booking.phone_number = '123455'
        booking.queue_alerts
      end
      
      it 'removes email alerts' do
        booking.update_attribute :state, 'cancelled'
        jobs = QueJob.where("args::json->2->>'booking_id' = ? AND job_class = 'SendEmail'", booking.id.to_s).to_a.reject! {
          |j| j.args[1] == 'booking_cancelled' || j.args[1] == 'user_cancellation'
        }
        expect(jobs.count).to eq(0)
      end
      
      it 'removes sms alerts' do
        booking.update_attribute :state, 'cancelled'
        jobs = QueJob.where("args::json->2->>'booking_id' = ? AND job_class = 'SendSMS'", booking.id.to_s)
        expect(jobs.count).to eq(0)
      end
      
    end
    
    it 'sends a cancellation email to the admin' do
      booking.update_attribute :state, 'cancelled'
      jobs = QueJob.where(job_class: 'SendEmail')
      expect(jobs.count).to eq(2)
      job = jobs.find { |j| j.args[1] == 'booking_cancelled' }
      expect(job.args[2]).to eq('booking_id' => booking.id)
    end
    
    it 'sends a cancellation email to the user' do
      booking.update_attribute :state, 'cancelled'
      jobs = QueJob.where(job_class: 'SendEmail')
      expect(jobs.count).to eq(2)
      job = jobs.find { |j| j.args[1] == 'user_cancellation' }
      expect(job.args[2]).to eq('booking_id' => booking.id)
    end
    
    it 'sends a cancellation sms' do
      booking.update_attribute :state, 'cancelled'
      job = QueJob.find_by(job_class: 'SendSMS')
      expect(job.args[0]['to']).to eq(booking.phone_number)
      expect(job.args[0]['template']).to eq('booking_cancellation')
      expect(job.args[0]['booking']).to eq(booking.id)
    end

    context 'when paying by card' do
      
      before do
        booking.charge_id = 'something'
      end
      
      it 'applies a refund' do
        expect(booking).to receive(:refund!)
        booking.update_attribute :state, 'cancelled'
      end
      
    end
    
  end
  
  describe '#create_payment', :stripe do
    
    context 'with a valid card' do
    
      before do
        booking.create_payment!(@stripe_helper.generate_card_token)
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
            route: route,
            start_time: DateTime.parse('2017-01-01T15:00:00'),
            reversed: true
          )
          booking.create_payment!(@stripe_helper.generate_card_token)
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
      
      it 'generates an error' do
        expect {
          booking.create_payment!(@stripe_helper.generate_card_token)
        }.to raise_error(Stripe::CardError, 'The card was declined')
      end
      
    end
    
  end
  
  describe '#refund', :stripe do
    
    before do
      booking.create_payment!(@stripe_helper.generate_card_token)
    end
    
    it 'refunds a charge' do
      booking.send(:refund!)
      charge = Stripe::Charge.retrieve(booking.charge_id)
      expect(charge.amount_refunded).to eq(booking.price_in_pence)
    end
    
  end
  
  describe 'number_of_adults' do
    
    let(:booking) { FactoryBot.create(:booking) }

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
    pickup_landmark = FactoryBot.create(:landmark, name: 'Pickup Landmark')
    dropoff_landmark = FactoryBot.create(:landmark, name: 'Dropoff Landmark')
    booking.pickup_landmark = pickup_landmark
    booking.dropoff_landmark = dropoff_landmark
    booking.save
    
    expect(booking.pickup_landmark).to eq(pickup_landmark)
    expect(booking.dropoff_landmark).to eq(dropoff_landmark)
  end
  
  describe 'csv rows' do
    
    before do
      booking.pickup_landmark.name = 'Pickup Landmark'
      booking.dropoff_landmark.name = 'Dropoff Landmark'
      booking.return_journey = FactoryBot.create(:journey,
        route: route,
        start_time: DateTime.parse('2017-01-01T15:00:00'),
        reversed: true
      )
    end
    
    it 'returns data without a journey specified' do
      expect(booking.csv_row).to eq([
        'Me',
        '12345',
        'me@example.com',
        journey.route.name,
        1,
        0,
        0,
        'Wheelchair',
        booking.created_at,
        4,
        'n',
        nil
      ])
    end
    
    it 'returns data for the outward journey' do
      expect(booking.csv_row(booking.journey)).to eq([
        Date.parse('2017-01-01'),
        'Me',
        '12345',
        'me@example.com',
        1,
        0,
        4,
        'n',
        nil,
        'outward',
        DateTime.parse('2017-01-01 10:00:00').in_time_zone('UTC'),
        'Pickup Stop',
        'Pickup Landmark',
        DateTime.parse('2017-01-01 11:25:00').in_time_zone('UTC'),
        'Dropoff Stop',
        'Dropoff Landmark',
        'Wheelchair',
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
        4,
        'n',
        nil,
        'return',
        DateTime.parse('2017-01-01 15:00:00').in_time_zone('UTC'),
        'Dropoff Stop',
        'Dropoff Landmark',
        DateTime.parse('2017-01-01 16:25:00').in_time_zone('UTC'),
        'Pickup Stop',
        'Pickup Landmark',
        'Wheelchair',
        booking.created_at
      ])
    end
    
    it 'shows as paid if paid by card' do
      booking.payment_method = 'card'
      booking.charge_id = 'abc123'
      expect(booking.csv_row(booking.journey)[7]).to eq('y')
      expect(booking.csv_row(booking.journey)[8]).to eq('abc123')
    end
    
  end
  
  describe 'token' do
    
    it 'generates a token' do
      expect(booking.token).to_not be_nil
    end
    
  end
  
  
  describe 'pricing' do
    
    {
      0..5 => [2,4,1,2],
      6..10 => [4,8,2,4],
      11..15 => [6,12,3,6],
      16..20 => [8,16,4,8],
      21..25 => [10,20,5,10],
      26..50 => [12,24,6,12]
    }.each do |range,fares|
      
      context "Between between #{range.first} and #{range.last} miles" do
        
        before do
          allow(booking).to receive(:price_distance).and_return(rand(range))
        end
        
        context 'adult fare' do
          
          before do
            booking.number_of_passengers = 1
          end
          
          it 'returns the correct single fare' do
            expect(booking.price).to eq(fares[0])
          end
          
          it 'returns the correct return fare' do
            allow(booking).to receive(:return_journey?).and_return(true)
            expect(booking.price).to eq(fares[1])
          end
          
        end
        
        context 'child fare' do
          
          before do
            booking.child_tickets = 1
          end
          
          it 'returns the correct single fare' do
            expect(booking.price).to eq(fares[2])
          end
          
          it 'returns the correct return fare' do
            allow(booking).to receive(:return_journey?).and_return(true)
            expect(booking.price).to eq(fares[3])
          end
          
        end
                
      end
      
    end
    
    it 'with pricing rules' do
      booking.route.pricing_rule = {
        child_single_price: 0,
        child_return_price: 0
      }
      booking.child_tickets = 1
      
      expect(booking.price).to eq(0)
      expect(booking.return_price).to eq(0)
    end
    
  end
  
end
