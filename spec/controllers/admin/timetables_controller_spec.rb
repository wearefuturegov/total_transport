require 'rails_helper'

RSpec.describe Admin::TimetablesController, type: :controller do
  login_supplier(true)
  
  let(:route) { FactoryBot.create(:route) }
  let(:vehicle) { FactoryBot.create(:vehicle) }
  let(:supplier) { FactoryBot.create(:supplier) }

  describe '#create' do
    
    let(:params) do
      {
        timetable: {
          from: DateTime.now,
          to: DateTime.now + 3.days,
          vehicle_id: vehicle.id,
          supplier_id: supplier.id,
          route_id: route.id,
          open_to_bookings: false,
          reversed: true,
          days: ['0', '1', '2', '3', '4', '5', '6'],
          timetable_times_attributes: [
            {
              time: '10:00'
            },
            {
              time: '14:00'
            }
          ]
        }
      }
    end
    
    before do
      post :create, params
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
            vehicle_id: vehicle.id,
            supplier_id: supplier.id,
            route_id: route.id,
            open_to_bookings: false,
            reversed: true,
            days: ['1', '2', '3', '4', '5'],
            timetable_times_attributes: [
              {
                time: '10:00'
              },
              {
                time: '14:00'
              }
            ]
          }
        }
      end
      
      it 'skips specific days' do
        expect(timetable.journeys.count).to eq(10)
      end
      
    end
    
  end
  
  
  
end
