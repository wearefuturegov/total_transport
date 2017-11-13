require 'rails_helper'

RSpec.describe JourneysController, type: :controller do
  
  let(:origin) { FactoryGirl.create(:place, name: 'Haverhill') }
  let(:destination) { FactoryGirl.create(:place, name: 'Newmarket') }
  let(:other_place) { FactoryGirl.create(:place, name: 'Somewhere Else') }
  let(:datetime) { '2017-01-01T09:00:00+00:00' }

  before(:each) { Timecop.freeze(datetime) }
  after(:each) { Timecop.return }
  
  let(:route) do
    FactoryGirl.create(:route, stops: [
      FactoryGirl.create(:stop),
      FactoryGirl.create(:stop, place: origin),
      FactoryGirl.create(:stop),
      FactoryGirl.create(:stop, place: destination)
    ])
  end
  
  let(:route2) do
    FactoryGirl.create(:route, stops: [
      FactoryGirl.create(:stop),
      FactoryGirl.create(:stop, place: destination),
      FactoryGirl.create(:stop),
      FactoryGirl.create(:stop, place: origin)
    ])
  end
  
  before do
    FactoryGirl.create_list(:journey, 2)
    FactoryGirl.create_list(:journey, 4, route: route, reversed: false)
    FactoryGirl.create_list(:journey, 3, route: route, reversed: true)
    FactoryGirl.create_list(:journey, 3, route: route2, reversed: false)
  end

  it 'renders a template' do
    expect(get :index).to render_template(:index)
  end
  
  it 'initialises a booking if there are availble journeys' do
    get :index, from: origin, to: destination
    bookings = assigns(:bookings)
    expect(bookings.count).to eq(1)
    expect(bookings.first.pickup_stop).to eq(route.stops[1])
    expect(bookings.first.dropoff_stop).to eq(route.stops[3])
  end
  
  it 'gets reversed journeys' do
    get :index, from: destination, to: origin
    bookings = assigns(:bookings)
    expect(bookings.count).to eq(2)
    expect(bookings.first.pickup_stop).to eq(route.stops[3])
    expect(bookings.first.dropoff_stop).to eq(route.stops[1])
    expect(bookings.last.pickup_stop).to eq(route2.stops[1])
    expect(bookings.last.dropoff_stop).to eq(route2.stops[3])
  end
  
  context 'if an origin does not have any routes', :que do
    
    let(:subject) { get :index, from: destination, to: other_place }
    
    it 'returns possible bookings' do
      subject
      possible_bookings = assigns(:possible_bookings)
      expect(possible_bookings.count).to eq(6)
      expect(possible_bookings.first[0].pickup_stop.place).to eq(destination)
      expect(possible_bookings.first[0].dropoff_stop.place).to eq(origin)
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
