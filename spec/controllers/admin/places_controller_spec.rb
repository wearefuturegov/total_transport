require 'rails_helper'

RSpec.describe Admin::PlacesController, type: :controller do
  login_supplier
  
  describe 'new' do
    subject { get :new }

    it 'initializes an empty place' do
      subject
      expect(assigns(:place)).to be_a(Place)
    end
    
    it 'renders the correct template' do
      expect(subject).to render_template('admin/places/new')
    end
    
    it 'sets the back path' do
      subject
      expect(assigns(:back_path)).to eq(admin_team_path)
    end
    
    context 'with a route id set' do
      subject { get :new, previous_route_id: 1 }

      it 'sets the back path' do
        subject
        expect(assigns(:back_path)).to eq(new_admin_route_stop_path(1))
      end
    end
  end
  
  describe 'create' do
    
    let(:params) {
      {
        place: {
          name: 'Some place',
          latitude: 55.8001,
          longitude: -6.0142,
          os_id: '34234344324234'
        }
      }
    }
    
    subject { post :create, params }

    it 'creates a place' do
      expect { subject }.to change { Place.count }.by(1)
      place = Place.last
      params[:place].each do |k,v|
        expect(place.send(k.to_sym)).to eq(v)
      end
    end
    
    it 'redirects to the back_path' do
      expect(subject).to redirect_to(admin_team_path)
    end
    
    context 'with a route id set' do
      subject { post :create, params.merge({
          previous_route_id: 1
        })
      }
      
      it 'redirect to the stop path' do
        expect(subject).to redirect_to(new_admin_route_stop_path(1))
      end
    end
    
    context 'with missing params' do
      
      let(:params) {
        {
          place: {
            name: 'Some place',
          }
        }
      }
      
      it 'does not redirect' do
        expect(subject).to render_template('admin/places/new')
      end
      
      it 'displays an error' do
        subject
        expect(flash[:error]).to match /Latitude can't be blank/
        expect(flash[:error]).to match /Longitude can't be blank/
        expect(flash[:error]).to match /You must specify a town or village/
      end
      
    end
  end

end
