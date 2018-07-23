require 'rails_helper'

RSpec.describe Admin::TimetablesController, type: :controller do
  login_supplier(true)
  
  let(:route) { FactoryBot.create(:route, stops_count: 5) }
  let(:team) { FactoryBot.create(:team) }

  describe '#create' do
    
    let(:params) do
      {
        timetable: {
          from: DateTime.now,
          to: DateTime.now + 3.days,
          team_id: team.id,
          route_id: route.id,
          open_to_bookings: false,
          reversed: true,
          days: ['0', '1', '2', '3', '4', '5', '6'],
          timetable_times_attributes: [
            {
              time: '10:00',
              seats: 5
            },
            {
              time: '14:00',
              seats: 7
            }
          ]
        }
      }
    end
    
    before do
      post :create, params: params
    end
    
    let(:timetable) { Timetable.first }
    let(:timetable_times) { timetable.timetable_times }

    it 'creates a timetable' do
      expect(timetable).to_not be_nil
    end
    
    it 'creates times' do
      expect(timetable_times.count).to eq(2)
    end
    
    it 'creates journeys' do
      expect(timetable_times.first.journeys.count).to eq(4)
      expect(timetable_times.last.journeys.count).to eq(4)
      expect(timetable_times.first.journeys.map { |t| t.start_time.strftime('%H:%M') }.uniq).to eq(['10:00'])
      expect(timetable_times.last.journeys.map { |t| t.start_time.strftime('%H:%M') }.uniq).to eq(['14:00'])
      expect(timetable_times.first.journeys.map { |t| t.open_to_bookings }.uniq).to eq([false])
      expect(timetable_times.last.journeys.map { |t| t.reversed }.uniq).to eq([true])
    end
    
    context 'with days' do
      
      let(:params) do
        {
          timetable: {
            from: Date.parse('2016-01-03'),
            to: Date.parse('2016-01-10'),
            team_id: team.id,
            route_id: route.id,
            open_to_bookings: false,
            reversed: true,
            days: ['1', '2', '3', '4', '5'],
            timetable_times_attributes: [
              {
                time: '10:00',
                seats: 5
              },
              {
                time: '14:00',
                seats: 7
              }
            ]
          }
        }
      end
      
      it 'skips specific days' do
        expect(timetable.journeys.count).to eq(10)
      end
      
    end
    
    context 'with stops' do
      
      let(:params) do
        {
          timetable: {
            from: Date.parse('2016-01-03'),
            to: Date.parse('2016-01-10'),
            team_id: team.id,
            route_id: route.id,
            open_to_bookings: false,
            reversed: true,
            days: ['1', '2', '3', '4', '5'],
            timetable_times_attributes: [
              {
                time: '10:00',
                seats: 10,
                stops: [
                  route.stops[2],
                  route.stops[3],
                  route.stops[4]
                ]
              },
              {
                time: '12:00',
                seats: 10,
                stops: [
                  route.stops[2],
                  route.stops[3],
                  route.stops[4]
                ]
              },
              {
                time: '15:00',
                seats: 10,
                stops: route.stops
              },
              {
                time: '17:00',
                seats: 10,
                stops: [
                  route.stops[2],
                  route.stops[3],
                  route.stops[4]
                ]
              }
            ]
          }
        }
      end
      
      it 'creates a new route' do
        new_route = timetable.timetable_times.first.journeys.first.route
        expect(new_route.stops.map(&:name)).to match_array([route.stops[2].name, route.stops[3].name, route.stops[4].name])
      end
      
      it 'creates the correct number of journeys' do
        expect(Journey.count).to eq(20)
      end
      
      it 'creates the right number of routes' do
        expect(Route.count).to eq(4)
        expect(Route.first.sub_routes.count).to eq(3)
      end
      
    end
    
  end
  
  describe '#destroy' do
      
    let(:timetable) do
      FactoryBot.create(:timetable,
        from: DateTime.now,
        to: DateTime.now + 3.days,
        timetable_times: [
          FactoryBot.create(:timetable_time, time: Time.parse('10:00'), seats: 4),
          FactoryBot.create(:timetable_time, time: Time.parse('14:00'), seats: 5),
          FactoryBot.create(:timetable_time, time: Time.parse('17:00'), seats: 6)
        ]
      )
    end
    
    it 'deletes the timetable' do
      delete :destroy, params: { id: timetable.id }
      expect(Timetable.count).to eq(0)
    end
    
    it 'deletes all associated records' do
      delete :destroy, params: { id: timetable.id }
      expect(TimetableTime.count).to eq(0)
      expect(Journey.count).to eq(0)
    end
        
  end

end
