require 'rails_helper'

RSpec.describe Admin::TeamsController, type: :controller do
  login_supplier(true)
  
  let(:team) { FactoryBot.create(:team, suppliers: []) }

  describe 'GET index' do
    
    let(:teams) { FactoryBot.create_list(:team, 5, suppliers: []) }
    
    it 'gets all teams' do
      get :index
      expect(assigns(:teams)).to eq([@supplier.team] + teams)
    end
    
    context 'when not an admin' do
      login_supplier
      
      it 'returns unauthorized' do
        get :index
        expect(response).to have_http_status(401)
      end

    end
    
  end
  
  describe 'GET edit' do
      
    it 'gets a team' do
      get :edit, params: { id: team }
      expect(assigns(:team)).to eq(team)
    end
    
  end
  
  describe 'PUT update' do
    
    let(:suppliers) { FactoryBot.create_list(:supplier, 3) }
    
    it 'updates a team' do
      put :update, params: {
        id: team,
        team: {
          name: 'New name',
          email: 'foo@example.com',
          suppliers_attributes: {
            '0' => {
              id: suppliers[0]
            },
            '1' => {
              id: suppliers[1]
            },
            '2' => {
              id: suppliers[2]
            }
          }
        }
      }
      
      team.reload
      expect(team.name).to eq('New name')
      expect(team.email).to eq('foo@example.com')
      expect(team.suppliers.count).to eq(3)
    end
    
    it 'updates a team without suppliers' do
      put :update, params: {
        id: team,
        team: {
          name: 'New name',
          email: 'foo@example.com'
        }
      }
      
      team.reload
      expect(team.name).to eq('New name')
      expect(team.email).to eq('foo@example.com')
    end
    
  end

end
