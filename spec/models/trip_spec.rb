require 'rails_helper'

RSpec.describe Trip, type: :model do
  
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
  let(:return_journey) { FactoryGirl.create(:journey, route: route, start_time: DateTime.parse('2017-01-01T10:00:00'), reversed: true) }
  let(:booking) {
    FactoryGirl.create(:booking,
      journey: journey,
      return_journey: return_journey,
      pickup_stop: stops.first,
      dropoff_stop: stops.last,
      passenger_name: 'Me',
      phone_number: '12345',
      email: 'me@example.com',
      pickup_landmark: stops.first.landmarks.first,
      dropoff_landmark: stops.last.landmarks.first,
    )
  }
  
  before do
    booking.pickup_landmark.name = 'Pickup Landmark'
    booking.dropoff_landmark.name = 'Dropoff Landmark'
  end
  
  context 'without a journey specified' do
    
    let(:trip) {
      FactoryGirl.build(:trip, booking: booking)
    }
    
    it 'is an outward trip' do
      expect(trip.outward?).to eq(true)
    end
    
    it 'has the corrct pickup stop' do
      expect(trip.pickup_stop.name).to eq('Pickup Stop')
    end
    
    it 'has the correct dropoff stop' do
      expect(trip.dropoff_stop.name).to eq('Dropoff Stop')
    end
    
    it 'has the correct pickup landmark' do
      expect(trip.pickup_landmark.name).to eq('Pickup Landmark')
    end
    
    it 'has the correct dropoff landmark' do
      expect(trip.dropoff_landmark.name).to eq('Dropoff Landmark')
    end
    
    it 'has the correct pickup name' do
      expect(trip.pickup_name).to eq('Pickup Landmark, Pickup Stop')
    end
    
    it 'has the correct dropoff name' do
      expect(trip.dropoff_name).to eq('Dropoff Landmark, Dropoff Stop')
    end
    
  end
  
  context 'with a journey specified' do
    
    let(:trip) {
      FactoryGirl.build(:trip, booking: booking, journey: return_journey)
    }
    
    it 'is a return trip' do
      expect(trip.outward?).to eq(false)
    end
    
    it 'has the corrct pickup stop' do
      expect(trip.pickup_stop.name).to eq('Dropoff Stop')
    end
    
    it 'has the correct dropoff stop' do
      expect(trip.dropoff_stop.name).to eq('Pickup Stop')
    end
    
    it 'has the correct pickup landmark' do
      expect(trip.pickup_landmark.name).to eq('Dropoff Landmark')
    end
    
    it 'has the correct dropoff landmark' do
      expect(trip.dropoff_landmark.name).to eq('Pickup Landmark')
    end
    
    it 'has the correct pickup name' do
      expect(trip.pickup_name).to eq('Dropoff Landmark, Dropoff Stop')
    end
    
    it 'has the correct dropoff name' do
      expect(trip.dropoff_name).to eq('Pickup Landmark, Pickup Stop')
    end
    
  end
  
  
end
