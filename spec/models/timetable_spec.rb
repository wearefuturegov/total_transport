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
    
  end
  
end
  
