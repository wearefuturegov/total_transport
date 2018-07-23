require 'rails_helper'

RSpec.describe Admin::PlacenamesController, type: :controller do
  login_supplier(true)
  
  describe '#index' do
    let(:query) { 'hello' }
    let(:service_response) {
      [
        {'foo' => 'bar'}
      ]
    }
    
    before do
      expect(PlacenamesService).to receive(:new).with(query) do
        service = double(PlacenamesService)
        expect(service).to receive(:search) { service_response }
        service
      end
    end
    
    it 'returns data from the PlacenamesService' do
      get :index, params: { query: query }
      expect(JSON.parse response.body).to eq(service_response)
    end
    
  end
    
end
