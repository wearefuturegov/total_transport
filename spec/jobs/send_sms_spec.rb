require 'rails_helper'

RSpec.describe SendSMS, type: :model do
  
  let(:service) { double(SmsService) }
  
  it 'runs a service without a model present' do
    params = { to: '1234', message: 'Some message' }
    expect(SmsService).to receive(:new).with(params) { service }
    expect(service).to receive(:perform)
    SendSMS.run(params)
  end
  
  it 'runs a service with a booking' do
    booking = FactoryBot.create(:booking)
    params = { to: '1234', template: :booking_notification, booking: booking.id }
    expected_params = params.merge(booking: booking)
    expect(SmsService).to receive(:new).with(expected_params) { service }
    expect(service).to receive(:perform)
    SendSMS.run(params)
  end
  
  it 'runs a service with a passenger' do
    passenger = FactoryBot.create(:passenger)
    params = { to: '1234', template: :verification_code, passenger: passenger.id }
    expected_params = params.merge(passenger: passenger)
    expect(SmsService).to receive(:new).with(expected_params) { service }
    expect(service).to receive(:perform)
    SendSMS.run(params)
  end
  
  context 'if the object no longer exists' do
    
    let!(:booking) { FactoryBot.create(:booking) }
    let(:params) { { to: '1234', template: :booking_notification, booking: booking.id } }
    before { booking.destroy }
    
    it 'does not run the service' do
      expect(SmsService).to_not receive(:new)
      SendSMS.run(params)
    end
    
    it 'destroys itself' do
      job = SendSMS.run(params)
      expect(job.instance_variable_get(:"@destroyed")).to eq(true)
    end
    
  end
  
end
