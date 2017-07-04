require 'rails_helper'

RSpec.describe SuggestedRoutesController, type: :controller do

  let(:passenger) { FactoryGirl.create(:passenger) }

  describe 'GET new' do

    it 'sets the correct vars' do
      get :new, nil, { current_passenger: passenger.id }

      expect(assigns(:page_title)).to eq('Suggest A Route')
      expect(assigns(:back_path)).to eq(routes_path)
      expect(assigns(:suggested_route)).to be_a(SuggestedRoute)
    end

  end

  describe 'POST create' do
    let(:description) { 'Some description' }
    let(:params) {
      {
        suggested_route: {
          description: description
        }
      }
    }

    it 'creates a suggested route' do
      post :create, params, { current_passenger: passenger.id }
      
      expect(SuggestedRoute.count).to eq(1)
      expect(SuggestedRoute.first.description).to eq(description)
      expect(SuggestedRoute.first.passenger).to eq(passenger)
    end
    
    it 'redirects to the routes index' do
      expect(
        post :create, params, { current_passenger: passenger.id }
      ).to redirect_to(routes_path)
    end
    
  end

end
