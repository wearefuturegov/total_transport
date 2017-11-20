require 'rails_helper'

RSpec.describe Admin::SuggestionsController, type: :controller do
  login_supplier(true)
  
  it 'gets all suggestions' do
    suggested_journeys = FactoryBot.create_list(:suggested_journey, 1)
    suggested_routes = FactoryBot.create_list(:suggested_route, 2)
    suggested_edit_to_stops = FactoryBot.create_list(:suggested_edit_to_stop, 3)
    supplier_suggestions = FactoryBot.create_list(:supplier_suggestion, 4)
    
    get :index
    
    expect(assigns(:suggested_journeys)).to eq(suggested_journeys)
    expect(assigns(:suggested_routes)).to eq(suggested_routes)
    expect(assigns(:suggested_edit_to_stops)).to eq(suggested_edit_to_stops)
    expect(assigns(:supplier_suggestions)).to eq(supplier_suggestions)
  end

end
