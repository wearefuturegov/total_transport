require 'rails_helper'

RSpec.describe Passenger, type: :model do
  
  context 'setup' do
    
    it 'creates a new passenger' do
      passenger = Passenger.setup('1234567')
      expect(Passenger.count).to eq(1)
      passenger.reload
      expect(passenger.verification_code).to_not be_nil
      expect(passenger.session_token).to_not be_nil
    end
    
    it 'gets an existing passenger' do
      passenger = FactoryGirl.create(:passenger)
      p = Passenger.setup(passenger.phone_number)
      expect(Passenger.count).to eq(1)
      expect(p.verification_code).to_not eq(passenger.verification_code)
      expect(p.session_token).to_not eq(passenger.session_token)
    end
    
    it 'sends a verification_code' do
      expect { Passenger.setup('1234567') }.to change { FakeSMS.messages.count }.by(1)
    end
    
  end
  
  it 'sends a verification code' do
    passenger = FactoryGirl.create(:passenger)
    expect { passenger.send_notification! }.to change { FakeSMS.messages.count }.by(1)
    message = FakeSMS.messages.last
    expect(message[:to]).to eq(passenger.phone_number)
    expect(message[:body]).to eq("Your verification code is #{passenger.verification_code}")
  end
  
end
