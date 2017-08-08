require 'rails_helper'

RSpec.describe SmsService, type: :model do
  
  it 'sends an ordinary notification' do
    sms = SmsService.new(to: '1234', message: 'Some message')
    expect { sms.perform }.to change { FakeSMS.messages.count }.by(1)
    expect(FakeSMS.messages.last[:to]).to eq('1234')
    expect(FakeSMS.messages.last[:body]).to eq('Some message')
  end
  
  it 'sends booking notification' do
    booking = FactoryGirl.create(:booking,
      pickup_stop: FactoryGirl.create(:stop, name: 'Sudbury'),
      dropoff_stop: FactoryGirl.create(:stop, name: 'Saffron Walden'),
      pickup_name: 'The Red Lion',
      journey: FactoryGirl.create(:journey, start_time: DateTime.parse('2017-01-02T09:00:00Z')),
    )
    sms = SmsService.new(to: '1234', template: :booking_notification, booking: booking)
    expect { sms.perform }.to change { FakeSMS.messages.count }.by(1)
    expect(FakeSMS.messages.last[:to]).to eq('1234')
    body = FakeSMS.messages.last[:body]
    expect(body).to match(/Your Pickup booking from Sudbury to Saffron Walden is confirmed/)
    expect(body).to match(/Your vehicle will pick you up from The Red Lion/)
    expect(body).to match(/Monday, 2 January between 10:30am and 10:50am/)
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
      pickup_stop: FactoryGirl.create(:stop, name: 'The Red Lion')
    )
    sms = SmsService.new(to: '1234', template: :first_alert, booking: booking)
    expect { sms.perform }.to change { FakeSMS.messages.count }.by(1)
    expect(FakeSMS.messages.last[:to]).to eq('1234')
    expect(FakeSMS.messages.last[:body]).to match(/This is a reminder that you will be picked up from The Red Lion tomorrow at 10:40 AM/)
  end
  
  it 'sends a second reminder' do
    booking = FactoryGirl.create(:booking,
      journey: FactoryGirl.create(:journey, start_time: DateTime.parse('2017-01-01T09:00:00Z')),
      pickup_stop: FactoryGirl.create(:stop, name: 'The Red Lion')
    )
    sms = SmsService.new(to: '1234', template: :second_alert, booking: booking)
    expect { sms.perform }.to change { FakeSMS.messages.count }.by(1)
    expect(FakeSMS.messages.last[:to]).to eq('1234')
    expect(FakeSMS.messages.last[:body]).to eq('You will be picked up from The Red Lion today at 10:40 AM')
  end
  
  it 'sends a generated journey notification' do
    booking = FactoryGirl.create(:booking,
      pickup_stop: FactoryGirl.create(:stop, name: 'Sudbury'),
      dropoff_stop: FactoryGirl.create(:stop, name: 'Saffron Walden'),
      journey: FactoryGirl.create(:journey, start_time: DateTime.parse('2017-03-01T10:30:00'))
    )
    sms = SmsService.new(to: '1234', template: :generated_journey, booking: booking)
    expect { sms.perform }.to change { FakeSMS.messages.count }.by(1)
    expect(FakeSMS.messages.last[:to]).to eq('1234')
    expect(FakeSMS.messages.last[:body]).to match /from Sudbury to Saffron Walden/
    expect(FakeSMS.messages.last[:body]).to match /on Wednesday, 1 March/
    expect(FakeSMS.messages.last[:body]).to match /The rough time for your pickup will be 12:10 PM/
    expect(FakeSMS.messages.last[:body]).to match /routes\/#{booking.route.id}\/bookings\/#{booking.id}\/edit_pickup_location/
  end
  
end
