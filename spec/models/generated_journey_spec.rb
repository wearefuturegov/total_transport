require 'rails_helper'

RSpec.describe GeneratedJourney, type: :model do
  
  let(:team_1) { FactoryGirl.create(:team, suppliers: FactoryGirl.create_list(:supplier, 2)) }
  let(:team_2) { FactoryGirl.create(:team, suppliers: FactoryGirl.create_list(:supplier, 3)) }
  
  let(:team_1_vehicles) { FactoryGirl.create_list(:vehicle, 5, team: team_1) }
  let(:team_2_vehicles) { FactoryGirl.create_list(:vehicle, 3, team: team_2) }

  let!(:generated_journey) {
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
  
  context 'approves a generated journey' do
    
    let(:supplier) { team_1.suppliers.first }
    let(:vehicle) { team_1_vehicles.first }
    
    let(:subject) { generated_journey.approve(supplier, vehicle, options) }
    
    context 'with no options' do
      let(:options) { Hash.new }
      
      it 'creates a journey' do
        expect { subject }.to change { Journey.count }.by(1)
      end
      
      it 'creates a journey with the correct parameters' do
        expect(subject.route).to eq(generated_journey.route)
        expect(subject.vehicle).to eq(vehicle)
        expect(subject.route).to eq(generated_journey.route)
        expect(subject.start_time).to eq(generated_journey.start_time)
        expect(subject.reversed?).to eq(generated_journey.reversed?)
        expect(subject.bookings).to eq(generated_journey.bookings)
      end
      
      it 'deletes the generated journey' do
        expect { subject }.to change { GeneratedJourney.count }.by(-1)
      end
    end
    
    context 'with options' do
      
      let(:options) {
        {
          start_time: DateTime.parse('2017-02-03T09:00:00Z'),
          open_to_bookings: false
        }
      }
      
      it 'creates a journey with the correct parameters' do
        expect(subject.start_time.to_s).to eq('2017-02-03 09:00:00 UTC')
        expect(subject.open_to_bookings).to eq(false)
      end

    end
    
  end
  
end
