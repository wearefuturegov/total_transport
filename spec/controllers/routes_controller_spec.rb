require 'rails_helper'

RSpec.describe RoutesController, type: :controller do

  let(:passenger) { FactoryGirl.create(:passenger) }

  describe "GET index" do
    it 'shows the correct title' do
      get :index, nil, { current_passenger: passenger.session_token }

      expect(assigns(:page_title)).to eq('Choose Your Route')
    end

    it 'shows bookable routes' do
      route1 = FactoryGirl.create(:route, stops_count: 5)
      route2 = FactoryGirl.create(:route, stops_count: 1)

      get :index, nil, { current_passenger: passenger.session_token }

      routes = assigns(:routes)
      expect(routes.count).to eq(1)
      expect(routes).to eq([route1])
    end
  end

end
