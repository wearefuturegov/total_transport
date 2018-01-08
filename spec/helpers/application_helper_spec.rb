require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  
  context '#friendly_date' do
    
    before { Timecop.freeze('2017-01-01') }
    after { Timecop.return }
    
    it 'returns today if date is today' do
      expect(friendly_date DateTime.parse('2017-01-01')).to eq('Today')
    end
    
    it 'returns today if date is tomorrow' do
      expect(friendly_date DateTime.parse('2017-01-02')).to eq('Tomorrow')
    end
    
    it 'parses date' do
      expect(friendly_date DateTime.parse('2017-05-23')).to eq('Tuesday, 23 May')
    end
    
    it 'parses date with length parameter' do
      expect(friendly_date DateTime.parse('2017-05-23'), true).to eq('Tue, 23 May')
    end
    
    context 'if the date is next year' do
      
      let(:date) { DateTime.parse('2018-04-17') }
      
      it 'parses date and appends year' do
        expect(friendly_date date).to eq('Tuesday, 17 Apr, 2018')
      end
      
      it 'parses date with length parameter and appends year' do
        expect(friendly_date date, true).to eq('Tue, 17 Apr, 2018')
      end
      
    end
    
  end
  
  context '#plus_minus_ten' do
    
    it 'returns a time period of twenty minutes' do
      time = Time.parse('10:00')
      expect(plus_minus_ten time).to eq(' 9:50am – 10:10am')
    end
    
  end
  
  context '#grab_phone_number' do
    
    let(:passenger) { FactoryBot.create(:passenger, phone_number: '123456') }
    let(:booking) { FactoryBot.create(:booking, passenger: passenger) }
    
    it 'returns the phone number if not changed' do
      expect(grab_phone_number nil, booking).to eq('123456')
    end
    
    it 'returns the new phone number if changed' do
      expect(grab_phone_number '654321', booking).to eq('654321 - number possibly changed from passenger\'s original (123456)')
    end
    
  end
  
end
