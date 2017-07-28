require 'rails_helper'

RSpec.describe GeneratedJourney, type: :model do
  
  let(:team_1) { FactoryGirl.create(:team, suppliers: FactoryGirl.create_list(:supplier, 2)) }
  let(:team_2) { FactoryGirl.create(:team, suppliers: FactoryGirl.create_list(:supplier, 3)) }
  
  let(:team_1_vehicles) { FactoryGirl.create_list(:vehicle, 5, team: team_1) }
  let(:team_2_vehicles) { FactoryGirl.create_list(:vehicle, 3, team: team_2) }

  let(:generated_journey) {
    FactoryGirl.create(:generated_journey,
      vehicles: team_1_vehicles + team_2_vehicles
    )
  }
  
  it 'groups vehicles by supplier' do
    vehicles_by_team = generated_journey.vehicles_by_team
    expect(vehicles_by_team[team_1].count).to eq(5)
    expect(vehicles_by_team[team_2].count).to eq(3)
  end
  
  it 'sends an email to all suppliers' do
    expect {
      FactoryGirl.create(:generated_journey,
        vehicles: team_1_vehicles + team_2_vehicles
      )
    }.to change { ActionMailer::Base.deliveries.count }.by(2)
  end
  
end
