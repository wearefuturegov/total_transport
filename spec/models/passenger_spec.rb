require 'rails_helper'

RSpec.describe Passenger, type: :model do
  
  let(:passenger) { FactoryBot.create(:passenger) }
  
  it 'anonymises a passenger' do
    passenger.anonymise!
    passenger.reload
    expect(passenger.name).to eq(nil)
    expect(passenger.email).to eq(nil)
    expect(passenger.phone_number).to eq(nil)
  end
  
  context '#format_phone_number' do
    
    it 'formats on create' do
      passenger = FactoryBot.build(:passenger, phone_number: '01473760072')
      passenger.save
      passenger.reload
      expect(passenger.phone_number).to eq('+441473760072')
    end
    
    it 'formats on update' do
      passenger.phone_number = '01473760072'
      passenger.save
      passenger.reload
      expect(passenger.phone_number).to eq('+441473760072')
    end
    
    it 'ignores the formatter if phone number has not changed' do
      expect(passenger).to_not receive(:format_phone_number)
      passenger.save
    end
    
  end
  
end
