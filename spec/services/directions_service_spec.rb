require 'rails_helper'

RSpec.describe DirectionsService, type: :model, webmock: true do
  
  let(:subject) {
    DirectionsService.new([
      '0.407962,52.24488',
      '0.462666,52.222596'
    ])
  }
  
  let(:url) {
    'https://api.mapbox.com/directions/v5/mapbox/driving/0.407962,52.24488;0.462666,52.222596.json?overview=full&access_token=someaccesstoken'
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
  
  it 'returns the geometry' do
    expect(subject.geometry).to be_a(Array)
    expect(Polylines::Encoder.encode_points subject.geometry).to eq("sa{}H_unAGFm@cBIUIUm@_AY]CDEBC?EAECAECG?I?GBGBGBCDAD@DBBFT[f@yBf@wC\\mBd@{C`@eCj@yCPcAf@sCr@uDRmAr@eEPi@TWpAoAr@w@POlAqAjBiBlAsArB{BRKTENC@_ABcBJmCV}Cr@eIp@mDd@mDj@iFb@_DnA_GlAsJdAyEj@}BZ}ChAgLViCvAmJf@qD^_Hh@}GvAiNl@wGl@uEx@qCzAaEnBwFnBuFzAyGzAaH~@eEpAeExAmGjCaIdAsDr@qDhAuHRu@|AsFFS`@qAvAgDpAaEnEvB|B|A~DbCpDvEVZhB|Al@^THb@Id@[r@g@LK")
  end
    
end
