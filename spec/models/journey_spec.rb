require 'rails_helper'

RSpec.describe Journey, type: :model do
  
  let(:journey) { FactoryBot.create(:journey) }
  
  context 'on_date' do
    
    it 'gets journeys on a particular day' do
      journeys_today = FactoryBot.create_list(:journey, 6, start_time: DateTime.now)
      journeys_later = FactoryBot.create_list(:journey, 6, start_time: DateTime.now + 4.days)
      
      expect(Journey.on_date(Date.today)).to eq(journeys_today)
      expect(Journey.on_date(Date.today + 4.days)).to eq(journeys_later)
    end
    
  end
  
  context 'by_route' do
    
    let(:single_route) { FactoryBot.create(:route) }
    let(:route_with_subroutes) do
      route = FactoryBot.create(:route)
      FactoryBot.create_list(:route, 5, route: route)
      route
    end

    let!(:single_journeys) { FactoryBot.create_list(:journey, 6, route: single_route) }
    let!(:subroute_journeys) { FactoryBot.create_list(:journey, 10, route: route_with_subroutes) }

    it 'gets journeys for a single route' do
      expect(Journey.by_route(single_route.id)).to match_array(single_journeys)
    end
    
    it 'gets journeys for a route and all subroutes' do
      expect(Journey.by_route(route_with_subroutes.id)).to match_array(subroute_journeys)
    end
    
    
  end
  
  it 'queues a job to close the journey for bookings' do
    Timecop.freeze('2016-12-23T09:00:00')
    start_time = DateTime.parse('2017-09-01T17:00:00')
    expect { FactoryBot.create(:journey, start_time: start_time) }.to change { QueJob.count }.by(1)
    expect(QueJob.last.run_at).to eq(DateTime.parse('2017-09-01T13:00:00'))
    Timecop.return
  end
  
  it 'takes business hours into account' do
    start_time = DateTime.parse('2017-09-01T08:00:00')
    expect { FactoryBot.create(:journey, start_time: start_time) }.to change { QueJob.count }.by(1)
    expect(QueJob.last.run_at).to eq(DateTime.parse('2017-08-31T15:30:00'))
  end
  
  it 'deletes and creates a new job if the journey time is changed' do
    Timecop.freeze('2016-12-23T09:00:00')
    start_time = DateTime.parse('2017-09-01T17:00:00')
    journey = FactoryBot.create(:journey)
    journey.start_time = start_time
    journey.save
    expect(QueJob.count).to eq(1)
    expect(QueJob.last.run_at).to eq(DateTime.parse('2017-09-01T13:00:00'))
    Timecop.return
  end
  
  it 'does not queue a job if the start time is not changed' do
    journey = FactoryBot.create(:journey)
    expect { journey.reversed = true ; journey.save }.to change { QueJob.count }.by(0)
  end
  
  context '#booked_bookings' do
    
    it 'returns all booked bookings' do
      booked_bookings = FactoryBot.create_list(:booking, 5, state: 'booked')
      unbooked_bookings = FactoryBot.create_list(:booking, 3)
      journey.bookings = booked_bookings + unbooked_bookings
      
      expect(journey.booked_bookings.to_a).to match_array(booked_bookings)
    end
    
  end
  
  context '#is_booked?' do
    
    it 'returns true if it has bookings' do
      journey.bookings = FactoryBot.create_list(:booking, 3, :booked)
      expect(journey.is_booked?).to eq(true)
    end
    
    it 'returns false if it has no bookings' do
      journey.bookings = []
      expect(journey.is_booked?).to eq(false)
    end
    
  end
  
  context '#seats_left' do
    
    it 'returns the correct number of seats left' do
      journey.seats = 11
      journey.bookings = FactoryBot.create_list(:booking, 3, state: 'booked', number_of_passengers: 2)
      
      expect(journey.seats_left).to eq(5)
    end
    
  end
  
  context '#route_name' do
    
    before do
      journey.route.stops.first.place.update_attribute(:name, 'First Stop')
      journey.route.stops.last.place.update_attribute(:name, 'Last Stop')
    end
    
    it 'returns first to last for non-reversed route' do
      expect(journey.route_name).to eq('First Stop - Last Stop')
    end
    
    it 'returns last to first for reversed route' do
      journey.reversed = true
      expect(journey.route_name).to eq('Last Stop - First Stop')
    end
    
  end
  
  context '#csv' do
    
    let!(:bookings) { FactoryBot.create_list(:booking, 6, :booked, journey: journey) }
    let!(:return_bookings) { FactoryBot.create_list(:booking, 8, :booked, return_journey: journey) }
    let(:csv) { CSV.parse(journey.csv) }
    
    it 'has the right number of rows' do
      expect(csv.count).to eq(15)
    end
    
    it 'returns the correct number of outward and return bookings' do
      expect(csv.select { |r| r[12] == 'outward' }.count).to eq(bookings.count)
      expect(csv.select { |r| r[12] == 'return' }.count).to eq(return_bookings.count)
    end
  
  end
  
  context '#duplicate' do
    
    let(:team) { FactoryBot.create(:team) }
    let(:route) { FactoryBot.create(:route) }
    let(:journey) {
      FactoryBot.create(:journey,
        start_time: '2016-01-01T09:00:00Z',
        seats: 5,
        team: team,
        open_to_bookings: true,
        reversed: false,
        route: route
      )
    }
    
    it 'duplicates a journey' do
      journey.duplicate(Date.parse('2016-01-02'), Date.parse('2016-01-10'))
      expect(Journey.count).to eq(10)
      (Date.parse('2016-01-02')..Date.parse('2016-01-10')).each_with_index do |d,i|
        j = Journey.all.to_a[i + 1]
        expect(j.seats).to eq(5)
        expect(j.team).to eq(team)
        expect(j.route).to eq(route)
        expect(j.start_time.to_date).to eq(d)
        expect(j.start_time.hour).to eq(9)
        expect(j.start_time.min).to eq(0)
      end
    end
    
    it 'duplicates only for given days' do
      journey.duplicate(Date.parse('2016-01-03'), Date.parse('2016-01-10'), [1,2,3,4,5])
      journeys = Journey.all.to_a - [journey]
      expect(journeys.count).to eq(5)
      days = (journeys).map { |j| j.start_time.wday }
      expect(days).to_not include(0)
      expect(days).to_not include(6)
    end
    
  end
  
end
