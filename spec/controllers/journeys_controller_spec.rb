require 'rails_helper'

RSpec.describe JourneysController, type: :controller do
  
  let(:origin) { FactoryBot.create(:place, name: 'Haverhill') }
  let(:destination) { FactoryBot.create(:place, name: 'Newmarket') }
  let(:other_place) { FactoryBot.create(:place, name: 'Somewhere Else') }
  let(:datetime) { '2017-01-01T09:00:00+00:00' }

  before(:each) { Timecop.freeze(datetime) }
  after(:each) { Timecop.return }
  
  let(:route) do
    FactoryBot.create(:route, stops: [
      FactoryBot.create(:stop),
      FactoryBot.create(:stop, place: origin),
      FactoryBot.create(:stop),
      FactoryBot.create(:stop, place: destination)
    ])
  end
  
  let(:route2) do
    FactoryBot.create(:route, stops: [
      FactoryBot.create(:stop),
      FactoryBot.create(:stop, place: destination),
      FactoryBot.create(:stop),
      FactoryBot.create(:stop, place: origin)
    ])
  end
  
  before do
    FactoryBot.create_list(:journey, 2)
    FactoryBot.create_list(:journey, 4, route: route, reversed: false)
    FactoryBot.create_list(:journey, 3, route: route, reversed: true)
    FactoryBot.create_list(:journey, 3, route: route2, reversed: false)
  end

  it 'renders a template' do
    expect(get :index).to render_template(:index)
  end
  
  it 'initialises a journey if there are availble journeys' do
    get :index, params: { from: origin, to: destination }
    journeys = assigns(:journeys)
    route = journeys.collect(&:route).uniq.first
    expect(journeys.count).to eq(4)
    expect(route.stops.collect(&:place)).to include(origin)
    expect(route.stops.collect(&:place)).to include(destination)
  end
  
  it 'gets reversed journeys' do
    get :index, params: { from: destination, to: origin }
    journeys = assigns(:journeys)
    route = journeys.collect(&:route).uniq.first
    expect(journeys.count).to eq(6)
    expect(route.stops.collect(&:place)).to include(origin)
    expect(route.stops.collect(&:place)).to include(destination)
  end
  
  context 'if an origin does not have any routes', :que do
    
    let(:subject) { get :index, params: { from: destination, to: other_place } }
    
    it 'returns possible destinations' do
      subject
      possible_destinations = assigns(:possible_destinations)
      expect(possible_destinations.count).to eq(5)
      expect(possible_destinations).to include(origin)
    end
    
    it 'queues a failure job' do
      expect { subject }.to change{
        QueJob.count
      }.by(1)
      job = QueJob.where(job_class: 'TrackFailedPlaceQuery').last
      expect(job.args).to eq([destination.name, other_place.name, datetime])
    end
    
  end
  
end
