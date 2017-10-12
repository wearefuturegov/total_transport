require 'rails_helper'

RSpec.describe Admin::StopsController, type: :controller do
  login_supplier
  
  let!(:route) { FactoryGirl.create(:route) }
  let!(:stop) { FactoryGirl.create(:stop, route: route) }
  
  context '#new' do
    
    it 'initializes a stop' do
      get :new, route_id: stop.route
      expect(assigns(:route)).to eq(route)
      expect(assigns(:stop)).to be_a(Stop)
    end
    
  end
    
  context '#edit' do
    
    it 'shows a stop' do
      get :edit, route_id: stop.route, id: stop
      expect(assigns(:stop)).to eq(stop)
    end
    
  end
  
  context '#create' do
    let(:params) {
      {
        stop: {
          place_id: FactoryGirl.create(:place).id,
          minutes_from_last_stop: 10,
        },
        route_id: route
      }
    }
    let(:subject) { post :create, params }
    
    it 'creates a stop' do
      expect { subject }.to change { Stop.count }.by(1)
    end
    
    it 'creates a stop with landmarks' do
      params[:stop][:landmarks_attributes] = [
        {
          name: 'Some landmark',
          latitude: '51.321313',
          longitude: '-1.23223'
        }
      ]
      
      expect { subject }.to change { Stop.count }.by(1)
      expect(Stop.last.landmarks.count).to eq(1)
    end
    
    it 'redirects to the route' do
      expect(subject).to redirect_to(admin_route_path(route))
    end
    
    it 'redirects to the create stop form' do
      params[:commit] = 'Create & add another stop'
      expect(subject).to redirect_to(new_admin_route_stop_path(route))
    end
    
  end
  
  context '#update' do
    let(:params) {
      {
        stop: {
          place_id: FactoryGirl.create(:place, name: 'New Place').id,
        },
        route_id: route,
        id: stop
      }
    }
    let(:subject) { post :update, params }
    
    it 'updates a stop' do
      expect { subject }.to change {
        stop.reload.place.name
      }.from(stop.place.name).to('New Place')
    end
    
    it 'adds a landmark' do
      params[:stop][:landmarks_attributes] = [
        {
          name: 'Some landmark',
          latitude: '51.321313',
          longitude: '-1.23223'
        }
      ]
      
      expect { subject }.to change {
        stop.reload.landmarks.count
      }.from(0).to(1)
    end
    
    it 'updates a landmark' do
      landmark = FactoryGirl.create(:landmark)
      stop.landmarks << landmark
      stop.save
      
      params[:stop][:landmarks_attributes] = [
        {
          id: landmark.id,
          name: 'Some landmark'
        }
      ]
      
      expect { subject }.to change {
        stop.reload.landmarks.first.name
      }.from(stop.landmarks.first.name).to('Some landmark')
    end
    
  end
  
  context '#destroy' do
    let(:subject) { post :destroy, route_id: stop.route, id: stop }

    it 'destroys a landmark' do
      expect { subject }.to change {
        Stop.count
      }.by(-1)
    end
    
  end

end
