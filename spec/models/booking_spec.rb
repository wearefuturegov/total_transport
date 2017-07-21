require 'rails_helper'

RSpec.describe Booking, type: :model do
  
  let(:booking) { FactoryGirl.create(:booking) }
  
  describe 'confirm!' do
    it 'sends a confirmation' do
      expect { booking.confirm! }.to change { FakeSMS.messages.count }.by(1)
      expect(FakeSMS.messages.last[:to]).to eq(booking.phone_number)
    end
    
    it 'queues alerts' do
      expect { booking.confirm! }.to change { QueJob.where(job_class: 'SendSMS').count }.by(2)
      jobs = QueJob.where(job_class: 'SendSMS')
      expect(jobs.first.run_at).to eq(booking.pickup_time - 24.hours)
      expect(jobs.first.args[0]['template']).to eq('first_alert')
      expect(jobs.last.run_at).to eq(booking.pickup_time - 1.hours)
      expect(jobs.last.args[0]['template']).to eq('second_alert')
    end
    
    it 'sets the journey to booked' do
      booking.confirm!
      expect(booking.journey.booked).to eq(true)
    end
    
    it 'sets the booking state to booked' do
      booking.confirm!
      expect(booking.state).to eq('booked')
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
      booking.pickup_stop.latitude = 51.7239162277052
      booking.pickup_stop.longitude = 0.899999141693115
      
      booking.dropoff_stop.latitude = 51.6275191853741
      booking.dropoff_stop.longitude = 0.814597606658936
      
      expect(booking.price_distance.round(1)).to eq(7.6)
    end
    
  end
  
  context '#last_dropoff_time' do
    
    let(:stops) {
      [
        FactoryGirl.create(:stop, minutes_from_last_stop: nil, position: 1),
        FactoryGirl.create(:stop, minutes_from_last_stop: 40, position: 2),
        FactoryGirl.create(:stop, minutes_from_last_stop: 20, position: 3),
        FactoryGirl.create(:stop, minutes_from_last_stop: 10, position: 4),
        FactoryGirl.create(:stop, minutes_from_last_stop: 15, position: 5)
      ]
    }
    let(:route) { FactoryGirl.create(:route, stops: stops) }
    let(:journey) { FactoryGirl.create(:journey, route: route, start_time: DateTime.parse('2017-01-01T10:00:00')) }
    let(:booking) {
      FactoryGirl.create(:booking,
        journey: journey,
        pickup_stop: stops.first,
        dropoff_stop: stops.last
      )
    }
    
    it 'gets the last dropoff time for a non-return booking' do
      expect(booking.last_dropoff_time.to_s).to eq('2017-01-01 11:25:00 UTC')
    end
    
    it 'gets the last dropoff time for a return booking' do
      booking.return_journey = FactoryGirl.create(:journey, route: route, reversed: true, start_time: DateTime.parse('2017-01-01T17:00:00'))
      expect(booking.last_dropoff_time.to_s).to eq('2017-01-01 18:25:00 UTC')
    end
    
  end
  
  context 'sets the journey boolean' do
    
    let(:journey) { booking.journey }
    before { booking.confirm! }
    
    it 'to false if there are no more bookings' do
      booking.destroy
      journey.reload
      expect(journey.booked).to eq(false)
    end
    
    it 'to true if there still other bookings' do
      journey.bookings << FactoryGirl.create_list(:booking, 2)
      journey.save
      booking.destroy
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
