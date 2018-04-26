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
  
end
