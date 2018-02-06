require 'rails_helper'

RSpec.describe Route, type: :model do
  let(:route) { FactoryBot.create(:route) }
  
  context 'allow_concessions' do
    
    it 'returns true by default' do
      expect(route.allow_concessions).to eq(true)
    end
    
  end
  
  it 'runs the SetRouteGeometry job after creation', :que do
    route = FactoryBot.create(:route)
    Route.set_callback(:save, :after, :queue_geometry)
    expect {
      route.save
    }.to change {
      QueJob.where(job_class: 'SetRouteGeometry').count
    }.by(1)
  end
  
  context 'flipped_geometery' do
    
    it 'returns an empty array by default' do
      expect(route.flipped_geometery).to eq([])
    end
    
    it 'flips the geometry' do
      route.geometry = [[52.2223, -1.6759]]
    end
    
  end
  
  context 'name' do
    
    it 'allows a name to be set' do
      route.name = 'Cool Route'
      route.save
      expect(route.name).to eq('Cool Route')
    end
    
    it 'returns a default' do
      expect(route.name).to eq("Route #{route.id}: #{route.stops.first.name} - #{route.stops.last.name}")
    end
    
  end
  
end
