require 'rails_helper'

RSpec.describe Admin::LandmarksController, type: :controller do
  login_supplier
  
  let(:route) { FactoryGirl.create(:route) }
  let(:stop) { FactoryGirl.create(:stop, route: route) }
  let(:params) {
    { route_id: route.id, stop_id: stop.id }
  }
  
  context '#index' do
    
    let!(:landmarks) { FactoryGirl.create_list(:landmark, 5, stop: stop) }
      
    it 'lists landmarks' do
      get :index, params
      expect(assigns(:landmarks)).to eq(landmarks)
    end
    
  end
  
  context '#new' do
    
    it 'initialises a blank landmark' do
      get :new, params
      expect(assigns(:landmark).stop).to eq(stop)
      expect(assigns(:back_path)).to eq(admin_route_stop_landmarks_path(route, stop))
    end
    
  end
  
  context '#create' do
    
    let(:subject) {
      post :create, params.merge({
        landmark: {
          name: 'My landmark',
          latitude: 51.3345,
          longitude: -1.43244
        }
      })
    }
    
    it 'creates a new landmark' do
      subject
      expect(assigns(:landmark).name).to eq('My landmark')
      expect(assigns(:landmark).latitude).to eq(51.3345)
      expect(assigns(:landmark).longitude).to eq(-1.43244)
      expect(Landmark.count).to eq(1)
    end
    
    it 'redirects' do
      expect(subject).to redirect_to(admin_route_stop_landmarks_path(route, stop))
    end
    
  end
  
  context '#edit' do
    
    let!(:landmark) { FactoryGirl.create(:landmark, stop: stop) }
    
    it 'loads the correct landmark' do
      get :edit, params.merge({
        id: landmark.id
      })
      expect(assigns(:landmark)).to eq(landmark)
      expect(assigns(:back_path)).to eq(admin_route_stop_landmarks_path(route, stop))
    end
    
  end
  
  context '#update' do
    
    let!(:landmark) { FactoryGirl.create(:landmark, stop: stop) }
    let(:subject) {
      put :update, params.merge({
        id: landmark.id,
        landmark: {
          name: 'New name',
          latitude: 51.3345,
          longitude: -1.43244
        }
      })
    }
    
    it 'updates the landmark' do
      subject
      landmark.reload
      expect(landmark.name).to eq('New name')
      expect(landmark.latitude).to eq(51.3345)
      expect(landmark.longitude).to eq(-1.43244)
    end
    
    it 'redirects' do
      expect(subject).to redirect_to(admin_route_stop_landmarks_path(route, stop))
    end
    
  end
  
  context '#destroy' do
    
    let!(:landmark) { FactoryGirl.create(:landmark, stop: stop) }
    let(:subject) {
      delete :destroy, params.merge({
        id: landmark.id
      })
    }
    
    it 'loads the correct landmark' do
      expect { subject }.to change(Landmark, :count).by(-1)
    end
    
    it 'redirects' do
      expect(subject).to redirect_to(admin_route_stop_landmarks_path(route, stop))
    end
    
  end

end
