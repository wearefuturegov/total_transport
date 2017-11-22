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
    expect(QueJob.last.run_at).to eq(DateTime.parse('2017-08-31T17:00:00'))
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
    
    it 'returns the correct number of seats left in a vehicle' do
      journey.vehicle = FactoryBot.create(:vehicle, seats: 11)
      journey.bookings = FactoryBot.create_list(:booking, 3, state: 'booked', number_of_passengers: 2)
      
      expect(journey.seats_left).to eq(5)
    end
    
  end
  
  context '#full?' do
    
    it 'returns true if there are the same number of passengers as seats' do
      journey.vehicle = FactoryBot.create(:vehicle, seats: 12)
      journey.bookings = FactoryBot.create_list(:booking, 6, state: 'booked', number_of_passengers: 2)
      
      expect(journey.full?).to eq(true)
    end
    
    it 'returns false if there are more seats than passengers' do
      journey.vehicle = FactoryBot.create(:vehicle, seats: 12)
      journey.bookings = FactoryBot.create_list(:booking, 3, state: 'booked', number_of_passengers: 2)
      
      expect(journey.full?).to eq(false)
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
      expect(csv.select { |r| r[9] == 'outward' }.count).to eq(bookings.count)
      expect(csv.select { |r| r[9] == 'return' }.count).to eq(return_bookings.count)
    end
  
  end
  
end
