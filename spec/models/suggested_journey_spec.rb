require 'rails_helper'

RSpec.describe SuggestedJourney, type: :model do
  
  it 'runs the dispatcher after creation' do
    expect {
      FactoryGirl.create(:suggested_journey)
    }.to change { QueJob.count }.by(1)
  end
  
end
