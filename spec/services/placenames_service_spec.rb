require 'rails_helper'

RSpec.describe PlacenamesService, type: :model, webmock: true do
  
  let(:query) { 'maldon' }
  let(:subject) { PlacenamesService.new(query) }
  let(:url) { "https://api.ordnancesurvey.co.uk/opennames/v1/find?query=#{query}&fq=LOCAL_TYPE:Town%20LOCAL_TYPE:City%20LOCAL_TYPE:Village%20LOCAL_TYPE:Hamlet&bounds=537525,180625,625918,248940&key=someapikey" }
  
  before(:each) do
    stub_const('PlacenamesService::API_KEY', 'someapikey')
    stub_request(:get, url).to_return(body: get_fixture('placenames_service/placenames.json'))
  end
  
  it 'sets the url correctly' do
    expect(subject.send(:url)).to eq(url)
  end
  
  it 'returns the correct results' do
    result = subject.search
    expect(result.count).to eq(1)
    expect(result.first['NAME1']).to eq('Maldon')
  end
  
  context 'with a partial query' do
    let(:query) { 'mal' }

    before(:each) do
      stub_request(:get, url).to_return(body: get_fixture('placenames_service/placenames_partial.json'))
    end
    
    it 'returns the correct results' do
      result = subject.search
      expect(result.count).to eq(6)
      expect(result.first['NAME1']).to eq('Maldon')
    end
    
  end
  
  context 'with no results' do
    let(:query) { 'sdasdasdsadsadsadasdasd' }

    before(:each) do
      stub_request(:get, url).to_return(body: get_fixture('placenames_service/no_results.json'))
    end
    
    it 'returns no results' do
      result = subject.search
      expect(result.count).to eq(0)
    end
  end
  
end
