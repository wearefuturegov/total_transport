require 'rails_helper'

RSpec.describe Admin::RoutesController, type: :controller do
  login_supplier(true)
  
  context '#index' do
    
    let(:routes) { FactoryBot.create_list(:route, 5) }
    let!(:subject) { get :index }
    
    it 'lists all the routes' do
      expect(assigns(:routes)).to eq(routes)
    end
    
    it 'initializes a new route' do
      expect(assigns(:route)).to be_a(Route)
    end
    
  end
  
  context '#show' do
    
    let!(:route) { FactoryBot.create(:route) }
    let!(:subject) {
      get :show, {
        id: route.id
      }
    }
    
    it 'shows a route' do
      expect(assigns(:route)).to eq(route)
    end
    
    it 'gets the back_page' do
      expect(assigns(:back_path)).to eq(admin_routes_path)
    end
    
  end
  
  context '#create' do
    
    let(:subject) {
      post :create
    }
    
    it 'creates a route' do
      subject
      expect(Route.count).to eq(1)
    end
    
    it 'redirects' do
      expect(subject).to redirect_to(admin_route_path(Route.last))
    end
    
  end
  
  context '#destroy' do
    
    let!(:route) { FactoryBot.create(:route) }
    let(:subject) {
      delete :destroy, {
        id: route.id
      }
    }
    
    it 'deletes a route' do
      expect { subject }.to change(Route, :count).by(-1)
    end
    
    it 'redirects' do
      expect(subject).to redirect_to(admin_routes_path)
    end
    
  end
  
  context '#sort' do
    
    let!(:route) { FactoryBot.create(:route, stops_count: 7) }
    
    it 'redirects the stop order' do
      stops = route.stops
      
      put :sort, {
        id: route.id,
        stop: [
          stops[0],
          stops[1],
          stops[3],
          stops[2],
          stops[5],
          stops[4],
          stops[6]
        ]
      }
      
      route.reload
      expect(route.stops.count).to eq(7)
      expect(route.stops[0]).to eq(stops[0])
      expect(route.stops[1]).to eq(stops[1])
      expect(route.stops[2]).to eq(stops[3])
      expect(route.stops[3]).to eq(stops[2])
      expect(route.stops[4]).to eq(stops[5])
      expect(route.stops[5]).to eq(stops[4])
      expect(route.stops[6]).to eq(stops[6])
    end
    
  end
  
  context 'sub routes' do
    
    let!(:sub_routes) { FactoryBot.create_list(:route, 3) }
    let!(:route) { FactoryBot.create(:route, sub_routes: sub_routes) }
    let(:sub_route) { sub_routes[0] }
    
    describe '#index' do
      
      let(:subject) {
        get :index, route_id: route
      }
      
      it 'gets subroutes for a route' do
        subject
        expect(assigns(:routes).to_a).to eq(sub_routes)
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
        expect(subject).to redirect_to(admin_route_path(Route.last))
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
    
    context '#sort' do
      
      let(:subject) { put :sort, route_id: route, id: sub_route, stop: [] }

      it 'gets a sub route' do
        subject
        expect(assigns(:route)).to eq(sub_route)
      end
    end
    
  end
  

end
