require 'rails_helper'

RSpec.describe DirectionsService, type: :model, webmock: true do
  
  let(:subject) {
    DirectionsService.new([
      '0.407962,52.24488',
      '0.462666,52.222596'
    ])
  }
  
  let(:url) {
    'https://api.mapbox.com/directions/v5/mapbox/driving/0.407962,52.24488;0.462666,52.222596.json?access_token=someaccesstoken'
  }
  
  before(:each) do
    stub_const('DirectionsService::ACCESS_TOKEN', 'someaccesstoken')
    stub_request(:get, url).to_return(body: get_fixture('directions_service/directions.json'))
  end
  
  it 'sets the correct url' do
    expect(subject.instance_variable_get('@url')).to eq(url)
  end
  
  it 'returns the total duration in minutes' do
    expect(subject.total_duration).to eq(7)
  end
    
end
