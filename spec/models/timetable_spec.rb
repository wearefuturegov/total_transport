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
        times: [
          {
            time: Time.parse('10:00')
          },
          {
            time: Time.parse('14:00')
          },
          {
            time: Time.parse('17:00')
          }
        ]
      )
    end
    
    before { timetable.reload }
    
    it 'creates journeys for a given time / date range' do
      expect(timetable.journeys.count).to eq(12)
    end
    
    it 'adds journey ids to times' do
      expect(timetable.times[0]['journeys'].count).to eq(4)
      expect(timetable.times[1]['journeys'].count).to eq(4)
      expect(timetable.times[2]['journeys'].count).to eq(4)
      timetable.times.each do |t|
        t['journeys'].each do |j|
          time = DateTime.parse(t['time']).strftime('%H:%M')
          expect(Journey.find(j).start_time.strftime('%H:%M')).to eq(time)
        end
      end
    end
    
  end
  
end
  
