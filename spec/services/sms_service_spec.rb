require 'rails_helper'

RSpec.describe SmsService, type: :model do
  
  it 'sends an ordinary notification' do
    sms = SmsService.new(to: '1234', message: 'Some message')
    expect { sms.perform }.to change { FakeSMS.messages.count }.by(1)
    expect(FakeSMS.messages.last[:to]).to eq('1234')
    expect(FakeSMS.messages.last[:body]).to eq('Some message')
  end
  
  context 'sends booking notification' do
    let(:booking) {
      FactoryGirl.create(:booking,
        pickup_stop: FactoryGirl.create(:stop, place: FactoryGirl.create(:place, name: 'Sudbury')),
        dropoff_stop: FactoryGirl.create(:stop, place: FactoryGirl.create(:place, name: 'Saffron Walden')),
        pickup_landmark: FactoryGirl.create(:landmark, name: 'The Red Lion'),
        journey: FactoryGirl.create(:journey, start_time: DateTime.parse('2017-01-02T09:00:00Z')),
      )
    }
    let(:sms) { SmsService.new(to: '1234', template: :booking_notification, booking: booking) }
    
    
    it 'without a return journey' do
      expect { sms.perform }.to change { FakeSMS.messages.count }.by(1)
      expect(FakeSMS.messages.last[:to]).to eq('1234')
      body = FakeSMS.messages.last[:body]
      expect(body).to match(/Your Ride booking from Sudbury to Saffron Walden is confirmed/)
      expect(body).to match(/Your vehicle will pick you up from The Red Lion/)
      expect(body).to match(/Monday, 2 Jan between 10:30am – 10:50am/)
    end
    
    it 'with a return journey' do
      booking.return_journey = FactoryGirl.create(:journey, start_time: DateTime.parse('2017-01-02T15:00:00Z'))
      booking.dropoff_landmark = FactoryGirl.create(:landmark, name: 'The White Horse')
      expect { sms.perform }.to change { FakeSMS.messages.count }.by(1)
      expect(FakeSMS.messages.last[:to]).to eq('1234')
      body = FakeSMS.messages.last[:body]
      expect(body).to match(/and returning from The White Horse, Saffron Walden/)
      expect(body).to match(/Monday, 2 Jan between 4:30pm – 4:50pm/)
    end
    
  end
  
  it 'sends a verification code' do
    passenger = FactoryGirl.create(:passenger, verification_code: 'abcd')
    sms = SmsService.new(to: '1234', template: :verification_code, passenger: passenger)
    expect { sms.perform }.to change { FakeSMS.messages.count }.by(1)
    expect(FakeSMS.messages.last[:to]).to eq('1234')
    expect(FakeSMS.messages.last[:body]).to eq('Your verification code is abcd')
  end
  
  it 'sends a first reminder' do
    booking = FactoryGirl.create(:booking,
      journey: FactoryGirl.create(:journey, start_time: DateTime.parse('2017-01-01T09:00:00Z')),
      pickup_stop: FactoryGirl.create(:stop, place: FactoryGirl.create(:place, name: 'Sudbury')),
      pickup_landmark: FactoryGirl.create(:landmark, name: 'The Red Lion'),
    )
    sms = SmsService.new(to: '1234', template: :first_alert, booking: booking)
    expect { sms.perform }.to change { FakeSMS.messages.count }.by(1)
    expect(FakeSMS.messages.last[:to]).to eq('1234')
    expect(FakeSMS.messages.last[:body]).to match(/Your Ride booking reminder. Your vehicle will collect you tomorrow from The Red Lion, Sudbury between 10:30am – 10:50am/)
  end
  
  it 'sends a second reminder' do
    booking = FactoryGirl.create(:booking,
      journey: FactoryGirl.create(:journey, start_time: DateTime.parse('2017-01-01T09:00:00Z')),
      pickup_stop: FactoryGirl.create(:stop, place: FactoryGirl.create(:place, name: 'Sudbury')),
      pickup_landmark: FactoryGirl.create(:landmark, name: 'The Red Lion')
    )
    sms = SmsService.new(to: '1234', template: :second_alert, booking: booking)
    expect { sms.perform }.to change { FakeSMS.messages.count }.by(1)
    expect(FakeSMS.messages.last[:to]).to eq('1234')
    expect(FakeSMS.messages.last[:body]).to match /Your pickup point is The Red Lion, Sudbury between 10:30am – 10:50am/  end
  
  it 'sends a cancellation confirmation' do
    booking = FactoryGirl.create(:booking,
      journey: FactoryGirl.create(:journey, start_time: DateTime.parse('2017-01-01T09:00:00Z')),
      pickup_stop: FactoryGirl.create(:stop, place: FactoryGirl.create(:place, name: 'Sudbury')),
      pickup_landmark: FactoryGirl.create(:landmark, name: 'The Red Lion')
    )
    sms = SmsService.new(to: '1234', template: :booking_cancellation, booking: booking)
    expect { sms.perform }.to change { FakeSMS.messages.count }.by(1)
    expect(FakeSMS.messages.last[:to]).to eq('1234')
    expect(FakeSMS.messages.last[:body]).to match /Your Ride booking on Sunday, 1 Jan at 9:00am from Sudbury has been cancelled/
  end
  
end
