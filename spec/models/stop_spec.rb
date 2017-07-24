require 'rails_helper'

RSpec.describe Stop, type: :model do
  
  let(:route) { FactoryGirl.create(:route, stops_count: 0) }
  let!(:stops) {
    [
      FactoryGirl.create(:stop, minutes_from_last_stop: nil, position: 1, route: route),
      FactoryGirl.create(:stop, minutes_from_last_stop: 40, position: 2, route: route),
      FactoryGirl.create(:stop, minutes_from_last_stop: 20, position: 3, route: route),
      FactoryGirl.create(:stop, minutes_from_last_stop: 10, position: 4, route: route),
      FactoryGirl.create(:stop, minutes_from_last_stop: 15, position: 5, route: route)
    ]
  }
  
  context '#previous_stops' do
    
    it 'gets previous stops' do
      expect(stops[0].previous_stops.to_a).to eq(stops[0..0])
      expect(stops[1].previous_stops.to_a).to eq(stops[0..1])
      expect(stops[2].previous_stops.to_a).to eq(stops[0..2])
      expect(stops[3].previous_stops.to_a).to eq(stops[0..3])
      expect(stops[4].previous_stops.to_a).to eq(stops[0..4])
    end
    
    it 'gets previous stops when route is reversed' do
      expect(stops[0].previous_stops(true).to_a).to eq(stops[0..4])
      expect(stops[1].previous_stops(true).to_a).to eq(stops[1..4])
      expect(stops[2].previous_stops(true).to_a).to eq(stops[2..4])
      expect(stops[3].previous_stops(true).to_a).to eq(stops[3..4])
      expect(stops[4].previous_stops(true).to_a).to eq(stops[4..4])
    end
    
  end
  
  context '#minutes_from_first_stop' do
    
    it 'gets the minutes from the first stop' do
      expect(stops[0].minutes_from_first_stop).to eq(0)
      expect(stops[1].minutes_from_first_stop).to eq(40)
      expect(stops[2].minutes_from_first_stop).to eq(60)
      expect(stops[3].minutes_from_first_stop).to eq(70)
      expect(stops[4].minutes_from_first_stop).to eq(85)
    end
    
    it 'gets the minutes from the first stop when route is reversed' do
      expect(stops[0].minutes_from_first_stop true).to eq(85)
      expect(stops[1].minutes_from_first_stop true).to eq(45)
      expect(stops[2].minutes_from_first_stop true).to eq(25)
      expect(stops[3].minutes_from_first_stop true).to eq(15)
      expect(stops[4].minutes_from_first_stop true).to eq(0)
    end
    
  end
  
  context '#journey_start_time' do
    
    it 'returns the start time of the journey' do
      
    end
    
  end
  
end
