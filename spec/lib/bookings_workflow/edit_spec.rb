require 'rails_helper'

RSpec.describe BookingsWorkflow::Edit, type: :model do
  include Rails.application.routes.url_helpers

  let(:route) { FactoryGirl.create(:route) }
  let(:booking) { FactoryGirl.create(:booking, pickup_stop: route.stops.first, dropoff_stop: route.stops.last) }
  let(:subject) { BookingsWorkflow::Edit.new(step, route, booking) }
  
  context 'if the step is not present in the steps constant' do
    let(:step) { :make_cake }
    
    it 'errors' do
      expect { subject }.to raise_error("Invalid step key!")
    end
  end
    
  context 'with requirements step' do
    let(:step) { :requirements }
    
    it 'gets a page title' do
      expect(subject.page_title).to eq('Choose Your Requirements')
    end
    
    it 'returns the correct back path' do
      expect(subject.back_path).to eq(new_route_booking_path(route))
    end
    
    it 'returns journeys' do
      journeys = FactoryGirl.create_list(:journey, 3, route: route)
      expect(subject.journeys.values.flatten).to eq(journeys)
    end
    
    it 'returns a template' do
      expect(subject.template).to eq('bookings/edit_requirements')
    end
    
    it 'returns allowed vars' do
      expect(subject.allowed_vars).to eq([:page_title, :back_path, :journeys])
    end
    
    context 'with reversed route' do
      let(:booking) { FactoryGirl.create(:booking, pickup_stop: route.stops.last, dropoff_stop: route.stops.first) }
      
      it 'returns journeys' do
        FactoryGirl.create_list(:journey, 3, route: route)
        journeys = FactoryGirl.create_list(:journey, 3, route: route, reversed: true)
        expect(subject.journeys.values.flatten).to eq(journeys)
      end
    end
  end
  
  context 'with journey step' do
    let(:step) { :journey }
    
    it 'gets a page title' do
      expect(subject.page_title).to eq('Choose Your Time Of Travel')
    end
    
    it 'returns the correct back path' do
      expect(subject.back_path).to eq(edit_requirements_route_booking_path(route, booking))
    end
    
    it 'returns map_type' do
      expect(subject.map_type).to eq(nil)
    end
    
    it 'returns a template' do
      expect(subject.template).to eq('bookings/edit_journey')
    end
    
    it 'returns allowed vars' do
      expect(subject.allowed_vars).to eq([:page_title, :back_path, :journeys])
    end
    
  end
  
  context 'with return_journey step' do
    let(:step) { :return_journey }
    
    it 'gets a page title' do
      expect(subject.page_title).to eq('Pick Your Return Time')
    end
    
    it 'returns the correct back path' do
      expect(subject.back_path).to eq(edit_journey_route_booking_path(route, booking))
    end
    
    it 'returns map_type' do
      expect(subject.map_type).to eq(nil)
    end
    
    it 'returns a template' do
      expect(subject.template).to eq('bookings/edit_return_journey')
    end
    
    it 'returns allowed vars' do
      expect(subject.allowed_vars).to eq([:page_title, :back_path, :journeys])
    end

  end
  
  context 'with pickup_location' do
    let(:step) { :pickup_location }
    
    it 'gets a page title' do
      expect(subject.page_title).to eq('Choose Pick Up Point')
    end
    
    it 'returns the return journey path' do
      expect(subject.back_path).to eq(edit_return_journey_route_booking_path(route, booking))
    end
    
    it 'returns map_type' do
      expect(subject.map_type).to eq('pickup')
    end
    
    it 'returns a template' do
      expect(subject.template).to eq('bookings/edit_pickup_dropoff_location')
    end
    
    it 'returns allowed vars' do
      expect(subject.allowed_vars).to eq([:page_title, :back_path, :stop, :map_type])
    end
    
  end
  
  context 'with dropoff_location step' do
    let(:step) { :dropoff_location }
    
    it 'gets a page title' do
      expect(subject.page_title).to eq('Choose Drop Off Point')
    end
    
    it 'returns the return journey path' do
      expect(subject.back_path).to eq(edit_pickup_location_route_booking_path(route, booking))
    end
    
    it 'returns map_type' do
      expect(subject.map_type).to eq('dropoff')
    end
    
    it 'returns a template' do
      expect(subject.template).to eq('bookings/edit_pickup_dropoff_location')
    end
    
    it 'returns allowed vars' do
      expect(subject.allowed_vars).to eq([:page_title, :back_path, :stop, :map_type])
    end

  end
  
  context 'with confirm step' do
    let(:step) { :confirm }
    
    it 'gets a page title' do
      expect(subject.page_title).to eq('Overview')
    end
    
    it 'returns the return journey path' do
      expect(subject.back_path).to eq(edit_dropoff_location_route_booking_path(route, booking))
    end
    
    it 'returns map_type' do
      expect(subject.map_type).to eq(nil)
    end
    
    it 'returns a template' do
      expect(subject.template).to eq('bookings/confirm')
    end
    
    it 'returns allowed vars' do
      expect(subject.allowed_vars).to eq([:page_title, :back_path])
    end

  end
  
  context 'with verify step' do
    let(:step) { :verify }

    it 'gets a page title' do
      expect(subject.page_title).to eq('Verify your phone number')
    end
    
    it 'returns the return journey path' do
      expect(subject.back_path).to eq(edit_confirm_route_booking_path(route, booking))
    end
    
    it 'returns map_type' do
      expect(subject.map_type).to eq(nil)
    end
    
    it 'returns a template' do
      expect(subject.template).to eq('bookings/verify')
    end
    
    it 'returns allowed vars' do
      expect(subject.allowed_vars).to eq([:page_title, :back_path])
    end
    
  end
  
end
