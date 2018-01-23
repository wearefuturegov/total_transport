require 'rails_helper'

RSpec.describe Admin::TimetablesController, type: :controller do
  login_supplier(true)
  
  let(:route) { FactoryBot.create(:route) }
  let(:vehicle) { FactoryBot.create(:vehicle) }
  let(:supplier) { FactoryBot.create(:supplier) }

  describe '#create' do
    
    before do
      post :create, {
        timetable: {
          from: DateTime.now,
          to: DateTime.now + 3.days,
          vehicle_id: vehicle.id,
          supplier_id: supplier.id,
          route_id: route.id,
          open_to_bookings: false,
          reversed: true,
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
    
  end
  
  
  
end
