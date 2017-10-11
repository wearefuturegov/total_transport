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
      get 'show', format: :json, id: id, name: 'Some Place'
    }
    let(:datetime) { '2017-01-01T09:00:00+00:00' }
    
    before(:each) { Timecop.freeze(datetime) }
    after(:each) { Timecop.return }

    it 'returns a 404' do
      subject
      expect(response.code).to eq('404')
    end
  it 'searches places' do
    FactoryGirl.create_list(:place, 5)
    
    place = FactoryGirl.create(:place, name: 'Some place')
    
    FactoryGirl.create(:route, stops: [
      FactoryGirl.create(:stop),
      FactoryGirl.create(:stop),
      FactoryGirl.create(:stop),
      FactoryGirl.create(:stop, place: place),
      FactoryGirl.create(:stop),
    ])
    
    FactoryGirl.create(:route, stops: [
      FactoryGirl.create(:stop),
      FactoryGirl.create(:stop, place: place),
      FactoryGirl.create(:stop),
      FactoryGirl.create(:stop),
    ])
        
    get 'index', format: :json, query: 'so'
    
    context 'with an origin' do
      
      let(:subject) {
        get 'show', format: :json, id: id, name: 'Some Place', origin: 'Some other place'
      }
      
      it 'queues up a metrics job' do
        expect { subject }.to change{
          QueJob.count
        }.by(1)
        expect(QueJob.last.job_class).to eq('TrackFailedPlaceQuery')
        expect(QueJob.last.args).to eq(['Some other place', 'Some Place', datetime])
      end
      
    end
    json = JSON.parse response.body
    
    expect(json.count).to eq(1)
    expect(json.first['name']).to eq('Some place')
  end
  
end
