require 'rails_helper'

RSpec.describe PlacesController, type: :controller, que: true do
  render_views
    
  it 'returns all places' do
    FactoryGirl.create_list(:place, 5)
    
    get 'index', format: :json
    
    json = JSON.parse response.body
    
    expect(json.count).to eq(5)
  end
  
  it 'gets a place by its OS ID' do
    place = FactoryGirl.create(:place, os_id: 12345)
    get 'show', format: :json, id: 12345
  
    json = JSON.parse response.body
    expect(json['name']).to eq(place.name)
  end
  
  context 'when an OS ID is not present' do
    
    let(:id) { 34567 }
    let(:subject) {
      get 'show', format: :json, id: id, type: 'origin', name: 'Some Place'
    }
    
    it 'returns a 404' do
      subject
      expect(response.code).to eq('404')
    end
    
    it 'queues up a metrics job' do
      expect { subject }.to change{
        QueJob.count
      }.by(1)
    end
    
  end
  
end
