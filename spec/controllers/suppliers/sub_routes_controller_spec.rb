require 'rails_helper'

RSpec.describe Admin::SubRoutesController, type: :controller do
  login_supplier(true)
      
  let!(:sub_routes) { FactoryBot.create_list(:route, 3) }
  let!(:route) { FactoryBot.create(:route, sub_routes: sub_routes) }
  let(:sub_route) { sub_routes[0] }
  
  describe '#index' do
    
    let(:subject) {
      get :index, route_id: route
    }
    
    it 'gets subroutes for a route' do
      subject
      expect(assigns(:routes)).to eq(sub_routes)
    end
    
  end
  
  context '#create' do
    
    let(:subject) {
      post :create, route_id: route
    }
    
    it 'creates a route' do
      expect { subject }.to change { Route.count }.by(1)
    end
    
    it 'creates a subroute' do
      subject
      expect(assigns(:route).route).to eq(route)
    end
    
    it 'copies the route' do
      subject
      sub_route = assigns(:route)
      expect(sub_route.stops.count).to eq(route.stops.count)
    end
    
    it 'redirects' do
      expect(subject).to redirect_to(admin_route_sub_route_path(route, Route.last))
    end
    
  end
  
  context '#show' do
    
    let(:subject) { get :show, route_id: route, id: sub_route }
    
    it 'gets a sub route' do
      subject
      expect(assigns(:route)).to eq(sub_route)
    end
    
  end
  
  context '#destroy' do
    
    let(:subject) { delete :destroy, route_id: route, id: sub_route }
    
    it 'gets the correct sub route' do
      subject
      expect(assigns(:route)).to eq(sub_route)
    end

    it 'removes a sub route' do
      expect { subject }.to change { Route.count }.by(-1)
    end
    
  end
  
end
