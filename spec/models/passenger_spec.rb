require 'rails_helper'

RSpec.describe Passenger, type: :model do
  
  it 'sends a verification code' do
    passenger = FactoryGirl.create(:passenger)
    expect { passenger.send_verification! }.to change { FakeSMS.messages.count }.by(1)
    message = FakeSMS.messages.last
    expect(message[:to]).to eq(passenger.phone_number)
    expect(message[:body]).to eq("Your verification code is #{passenger.verification_code}")
  end
  
end
