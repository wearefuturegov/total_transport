require 'rails_helper'

RSpec.describe Admin::GeneratedJourneysController, type: :controller do
  login_supplier
  
  let(:team_1) { FactoryGirl.create(:team, suppliers: [@supplier]) }
  let(:team_2) { FactoryGirl.create(:team) }
  
  let(:team_1_vehicle_1) { FactoryGirl.create(:vehicle, seats: 4, team: team_1) }
  let(:team_1_vehicle_2) { FactoryGirl.create(:vehicle, seats: 4, team: team_1) }
  let(:team_2_vehicle) { FactoryGirl.create(:vehicle, seats: 4, team: team_2) }
  
  describe '#index' do

    let!(:team_journeys) {
      FactoryGirl.create_list(:generated_journey, 4, vehicles: [team_1_vehicle_1]) +
      FactoryGirl.create_list(:generated_journey, 3, vehicles: [team_1_vehicle_2, team_2_vehicle]) +
      FactoryGirl.create_list(:generated_journey, 2, vehicles: [team_1_vehicle_1, team_1_vehicle_2])
    }
    
    let!(:other_journeys) { FactoryGirl.create_list(:generated_journey, 4, vehicles: [team_2_vehicle]) }
    
    it 'lists generated journeys for a team' do
      get :index
      expect(assigns(:generated_journeys).to_a).to eq(team_journeys)
    end
    
  end
  
  describe '#edit' do
    
    let(:generated_journey) { FactoryGirl.create(:generated_journey, vehicles: [team_1_vehicle_1]) }
    
    it 'shows a journey' do
      get :edit, { id: generated_journey.id }
      expect(assigns(:generated_journey)).to eq(generated_journey)
    end
    
  end
  
  describe '#approve' do
    
    let(:route) { FactoryGirl.create(:route) }
    let(:bookings) {
      FactoryGirl.create_list(:booking, 5,
        journey: nil,
        pickup_stop: route.stops[0],
        dropoff_stop: route.stops[3]
      )
    }
    let(:generated_journey) {
      FactoryGirl.create(:generated_journey,
        vehicles: [team_1_vehicle_1, team_1_vehicle_2],
        bookings: bookings,
        route: route
      )
    }
    let(:subject) {
      put :approve, {
        id: generated_journey.id,
        generated_journey: {
          vehicle_id: team_1_vehicle_1.id,
        }
      }
    }
    
    it 'creates a journey' do
      expect { subject }.to change { Journey.count }.by(1)
    end
    
    it 'creates a journey with the correct things' do
      subject
      journey = Journey.last
      expect(journey.vehicle).to eq(team_1_vehicle_1)
      expect(journey.start_time).to eq(generated_journey.start_time)
      expect(journey.bookings).to eq(bookings)
      expect(journey.reversed?).to eq(false)
    end
    
    context 'for reversed bookings' do
      
      let(:bookings) {
        FactoryGirl.create_list(:booking, 5,
          journey: nil,
          pickup_stop: route.stops[3],
          dropoff_stop: route.stops[0]
        )
      }
      
      it 'sets journey to reversed' do
        subject
        journey = Journey.last
        expect(journey.reversed?).to eq(true)
      end
      
    end
    
  end

end
