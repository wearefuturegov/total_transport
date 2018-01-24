require 'rails_helper'

RSpec.describe Timetable, type: :model do
  
  let(:vehicle) { FactoryBot.create(:vehicle) }
  let(:supplier) { FactoryBot.create(:supplier) }
  let(:route) { FactoryBot.create(:route) }

  describe 'create_journeys' do
    
    let(:timetable) do
      FactoryBot.create(:timetable,
        from: DateTime.now,
        to: DateTime.now + 3.days,
        timetable_times: [
          FactoryBot.create(:timetable_time, time: Time.parse('10:00')),
          FactoryBot.create(:timetable_time, time: Time.parse('14:00')),
          FactoryBot.create(:timetable_time, time: Time.parse('17:00'))
        ]
      )
    end
    
    before { timetable.reload }
    
    it 'creates journeys for a given time / date range' do
      expect(timetable.journeys.count).to eq(12)
    end
    
    it 'adds journey ids to times' do
      expect(timetable.timetable_times[0].journeys.count).to eq(4)
      expect(timetable.timetable_times[1].journeys.count).to eq(4)
      expect(timetable.timetable_times[2].journeys.count).to eq(4)
      timetable.timetable_times.each do |t|
        t.journeys.each do |j|
          expect(j.start_time.strftime('%H:%M')).to eq(t.time.strftime('%H:%M'))
        end
      end
    end
    
    context 'with days' do
      
      let(:timetable) do
        FactoryBot.create(:timetable,
          from: Date.parse('2016-01-03'),
          to: Date.parse('2016-01-10'),
          timetable_times: [
            FactoryBot.create(:timetable_time, time: Time.parse('10:00')),
            FactoryBot.create(:timetable_time, time: Time.parse('14:00')),
            FactoryBot.create(:timetable_time, time: Time.parse('17:00'))
          ],
          days: [1,2,3,4,5]
        )
      end
      
      it 'skips specific days' do
        expect(timetable.journeys.count).to eq(15)
        days = timetable.journeys.map { |j| j.start_time.wday }
        expect(days).to_not include(0)
        expect(days).to_not include(6)
      end
      
    end
    
    context 'with routes' do
      
      let(:route) { FactoryBot.create(:route, stops_count: 5)}
      let(:timetable) do
        FactoryBot.create(:timetable,
          from: Date.parse('2016-01-03'),
          to: Date.parse('2016-01-04'),
          route: route,
          timetable_times: [
            FactoryBot.create(:timetable_time, time: Time.parse('10:00'), stops: route.stops.map(&:id)),
            FactoryBot.create(:timetable_time, time: Time.parse('10:00'), stops: [
              route.stops[1].id,
              route.stops[2].id,
              route.stops[3].id
            ])
          ]
        )
      end
      
      it 'uses the existing route if all stops are specified' do
        expect(timetable.timetable_times.first.journeys.first.route).to eq(route)
      end
      
      it 'creates a new subroute' do
        new_route = timetable.timetable_times.last.journeys.first.route
        expect(new_route.stops.map(&:name)).to match_array([route.stops[1].name, route.stops[2].name, route.stops[3].name])
      end
      
    end
    
  end
  
end
  
