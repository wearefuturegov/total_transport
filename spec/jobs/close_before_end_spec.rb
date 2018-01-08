require 'rails_helper'

RSpec.describe CloseBeforeEnd, type: :model do
  
  it 'closes a journey for bookings' do
    expect_any_instance_of(CloseBeforeEnd).to receive(:destroy)
    journey = FactoryBot.create(:journey, open_to_bookings: true)
    CloseBeforeEnd.run(journey.id)
    journey.reload
    expect(journey.open_to_bookings).to eq(false)
  end
  
  it 'destroys the job if the ID is not found' do
    expect_any_instance_of(CloseBeforeEnd).to receive(:destroy)
    CloseBeforeEnd.run(12345)
  end
  
end
