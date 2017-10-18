require 'rails_helper'

RSpec.describe Passenger, type: :model do
  
  context 'setup' do
    
    it 'creates a new passenger' do
      passenger = Passenger.setup('1234567')
      expect(Passenger.count).to eq(1)
      passenger.reload
      expect(passenger.session_token).to_not be_nil
    end
    
    it 'gets an existing passenger' do
      passenger = FactoryGirl.create(:passenger)
      p = Passenger.setup(passenger.phone_number)
      expect(Passenger.count).to eq(1)
      expect(p.session_token).to_not eq(passenger.session_token)
    end
    
  end
  
end
