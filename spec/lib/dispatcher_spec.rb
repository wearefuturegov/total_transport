require 'rails_helper'

RSpec.describe Dispatcher, type: :model do

  let(:route) do
    FactoryGirl.create(:route, stops: [
        FactoryGirl.create(:stop, name: 'Bradwell', minutes_from_last_stop: 0, position: 1),
        FactoryGirl.create(:stop, name: 'Tillingham', minutes_from_last_stop: 5, position: 2),
        FactoryGirl.create(:stop, name: 'Asheldham', minutes_from_last_stop: 10, position: 3),
        FactoryGirl.create(:stop, name: 'Southminster', minutes_from_last_stop: 7, position: 4),
        FactoryGirl.create(:stop, name: 'Burnham-On-Crouch', minutes_from_last_stop: 13, position: 5),
        FactoryGirl.create(:stop, name: 'Dengie', minutes_from_last_stop: 6, position: 6)
    ])
  end
  
  let(:suggested_journey) do
    FactoryGirl.create(:suggested_journey,
      route: route,
      start_time: DateTime.parse('2017-01-01T10:00:00'),
      booking: FactoryGirl.create(:booking, pickup_stop: route.stops[0], dropoff_stop: route.stops[3], journey: nil)
    )
  end
  
  context 'with a successful match' do
    
    let(:dispatcher) { Dispatcher.new(suggested_journey) }
    
    before do
      # Create some suggested journeys
      FactoryGirl.create(:suggested_journey,
        route: route,
        start_time: DateTime.parse('2017-01-01T10:20:00'),
        booking: FactoryGirl.create(:booking, pickup_stop: route.stops[3], dropoff_stop: route.stops[5], journey: nil)
      )
      FactoryGirl.create(:suggested_journey,
        route: route,
        start_time: DateTime.parse('2017-01-01T09:30:00'),
        booking: FactoryGirl.create(:booking, pickup_stop: route.stops[1], dropoff_stop: route.stops[4], journey: nil)
      )
      FactoryGirl.create(:suggested_journey,
        route: route,
        start_time: DateTime.parse('2017-01-01T10:30:00'),
        booking: FactoryGirl.create(:booking, pickup_stop: route.stops[2], dropoff_stop: route.stops[3], journey: nil)
      )
      FactoryGirl.create(:suggested_journey,
        route: route,
        start_time: DateTime.parse('2017-01-01T09:40:00'),
        booking: FactoryGirl.create(:booking, pickup_stop: route.stops[2], dropoff_stop: route.stops[5], journey: nil, number_of_passengers: 2)
      )
      # Same route, reversed
      FactoryGirl.create(:suggested_journey,
        route: route,
        start_time: DateTime.parse('2017-01-01T09:40:00'),
        booking: FactoryGirl.create(:booking, pickup_stop: route.stops[5], dropoff_stop: route.stops[2], journey: nil, number_of_passengers: 2)
      )
      # Same route, different day
      FactoryGirl.create(:suggested_journey,
        route: route,
        start_time: DateTime.parse('2017-01-01T17:00:00'),
        booking: FactoryGirl.create(:booking, pickup_stop: route.stops[2], journey: nil)
      )
      # Different route, same time
      FactoryGirl.create(:suggested_journey,
        route: FactoryGirl.create(:route),
        start_time: DateTime.parse('2017-01-01T10:00:00'),
        booking: FactoryGirl.create(:booking, pickup_stop: route.stops[2], journey: nil)
      )
      # Same route, different day
      FactoryGirl.create(:suggested_journey,
        route: route,
        start_time: DateTime.parse('2017-01-02T11:00:00'),
        booking: FactoryGirl.create(:booking, pickup_stop: route.stops[2], journey: nil)
      )
      
      # Create some teams and vehicles
      team_1 = FactoryGirl.create(:team)
      team_2 = FactoryGirl.create(:team)
      
      FactoryGirl.create(:vehicle, seats: 4, team: team_1)
      FactoryGirl.create(:vehicle, seats: 4, team: team_2)
      
      FactoryGirl.create(:vehicle, seats: 6, team: team_1, make_model: 'Cool Vehicle')
      FactoryGirl.create(:vehicle, seats: 12, team: team_2, make_model: 'Big Vehicle')
    end
    
    it 'returns suggested journeys' do
      expect(dispatcher.send(:suggested_journeys).count).to eq(5)
    end
    
    it 'returns possible teams' do
      expect(dispatcher.send(:possible_teams).count).to eq(1)
      expect(dispatcher.send(:possible_teams).first.name).to eq('Supplier 1\'s Team')
    end
    
    it 'returns possible vehicles' do
      expect(dispatcher.send(:possible_vehicles).count).to eq(1)
      expect(dispatcher.send(:possible_vehicles).first.make_model).to eq('Cool Vehicle')
    end
    
    it 'returns a start time' do
      expect(dispatcher.send(:start_time)).to eq(DateTime.parse('2017-01-01T10:00:00'))
    end
    
    context '#perform' do
      
      let(:journey) { dispatcher.perform! && GeneratedJourney.first }
      
      it 'creates a generated journey' do
        expect(journey.start_time).to eq(DateTime.parse('2017-01-01T10:00:00'))
        expect(journey.route).to eq(suggested_journey.route)
      end
      
      it 'creates bookings' do
        expect(journey.bookings.count).to eq(5)
        bookings = journey.bookings.sort_by { |b| b.pickup_stop }
        expect(bookings[0].pickup_stop).to eq(suggested_journey.booking.pickup_stop)
      end
      
    end
    
  end
  
end
