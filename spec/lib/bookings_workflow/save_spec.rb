require 'rails_helper'

RSpec.describe BookingsWorkflow::Save, type: :model do
  include Rails.application.routes.url_helpers

  let(:route) { FactoryGirl.create(:route) }
  let(:booking) { FactoryGirl.create(:booking) }
  let(:journey) { FactoryGirl.create(:journey) }
  let(:subject) { BookingsWorkflow::Save.new(step, route, booking, params) }
  let(:promo_code) { FactoryGirl.create(:promo_code) }
  let(:params) {
    ActionController::Parameters.new({
      number_of_passengers: 1,
      promo_code: promo_code.code,
      child_tickets: 0,
      older_bus_passes: 1,
      disabled_bus_passes: 1,
      scholar_bus_passes: 1,
      special_requirements: 'Foo bar baz',
      journey_id: journey.id,
      pickup_lat: 52.4323,
      pickup_lng: -1.4234,
      pickup_name: 'Somewhere',
      dropoff_lat: 52.4323,
      dropoff_lng: -1.4234,
      dropoff_name: 'Somewhere',
      passenger_name: 'Me',
      phone_number: '1234',
      payment_method: 'cash'
    })
  }
    
  context 'if the step is not present in the steps constant' do
    let(:step) { :make_cake }
    
    it 'errors' do
      expect { subject }.to raise_error("Invalid step key!")
    end
  end
  
  context 'with requirements step' do
    let(:step) { :requirements }
    
    it 'returns the correct redirect path' do
      expect(subject.redirect_path).to eq(edit_journey_route_booking_path(route, booking))
    end
    
    it 'returns the correct params' do
      expect(subject.params).to eq(ActionController::Parameters.new({
        number_of_passengers: 1,
        child_tickets: 0,
        older_bus_passes: 1,
        disabled_bus_passes: 1,
        scholar_bus_passes: 1,
        special_requirements: 'Foo bar baz'
      }))
    end
    
    it 'updates the correct atttributes' do
      subject.perform_actions!
      subject.params.each do |k,v|
        expect(booking.send(k)).to eq(v)
      end
    end
    
    # it 'sets the promo code' do
    #   expect(booking.promo_code).to eq(promo_code)
    # end
  end
  
  context 'with journey step' do
    let(:step) { :journey }
    
    it 'returns the correct redirect path' do
      expect(subject.redirect_path).to eq(edit_return_journey_route_booking_path(route, booking))
    end
    
    it 'returns the correct params' do
      expect(subject.params).to eq(ActionController::Parameters.new({
        journey_id: journey.id
      }))
    end
    
    it 'updates the correct atttributes' do
      subject.perform_actions!
      subject.params.each do |k,v|
        expect(booking.send(k)).to eq(v)
      end
    end
    
    context 'single journeys' do
      let(:subject) {
        single_params = params.merge(ActionController::Parameters.new({
          single_journey: 1
        }))
        BookingsWorkflow::Save.new(step, route, booking, single_params)
      }
      
      it 'skips the return journey' do
        expect(subject.redirect_path).to eq(edit_pickup_location_route_booking_path(route, booking))
      end
    end
  end
  
  context 'with return_journey step' do
    let(:step) { :return_journey }
    
    it 'returns the correct redirect path' do
      expect(subject.redirect_path).to eq(edit_pickup_location_route_booking_path(route, booking))
    end
    
    it 'returns the correct params' do
      expect(subject.params).to eq(ActionController::Parameters.new({
        journey_id: journey.id
      }))
    end
    
    it 'updates the correct atttributes' do
      subject.perform_actions!
      subject.params.each do |k,v|
        expect(booking.send(k)).to eq(v)
      end
    end
  end
  
  context 'with pickup_location step' do
    let(:step) { :pickup_location }
    
    it 'returns the correct redirect path' do
      expect(subject.redirect_path).to eq(edit_dropoff_location_route_booking_path(route, booking))
    end
    
    it 'returns the correct params' do
      expect(subject.params).to eq(ActionController::Parameters.new({
        pickup_lat: 52.4323,
        pickup_lng: -1.4234,
        pickup_name: 'Somewhere'
      }))
    end
    
    it 'updates the correct atttributes' do
      subject.perform_actions!
      subject.params.each do |k,v|
        expect(booking.send(k)).to eq(v)
      end
    end
  end
  
  context 'with dropoff_location step' do
    let(:step) { :dropoff_location }
    
    it 'returns the correct redirect path' do
      expect(subject.redirect_path).to eq(edit_confirm_route_booking_path(route, booking))
    end
    
    it 'returns the correct params' do
      expect(subject.params).to eq(ActionController::Parameters.new({
        dropoff_lat: 52.4323,
        dropoff_lng: -1.4234,
        dropoff_name: 'Somewhere'
      }))
    end
    
    it 'updates the correct atttributes' do
      subject.perform_actions!
      subject.params.each do |k,v|
        expect(booking.send(k)).to eq(v)
      end
    end
  end
  
  context 'with confirm step' do
    let(:step) { :confirm }
    
    it 'returns the correct redirect path' do
      expect(subject.redirect_path).to eq(confirmation_route_booking_path(route, booking))
    end
    
    it 'returns the correct params' do
      expect(subject.params).to eq(ActionController::Parameters.new({
        passenger_name: 'Me',
        phone_number: '1234',
        payment_method: 'cash'
      }))
    end
    
    it 'updates the correct atttributes' do
      subject.perform_actions!
      subject.params.each do |k,v|
        expect(booking.send(k)).to eq(v)
      end
    end
    
    it 'sends a confirmation' do
      expect(booking).to receive(:confirm!)
      subject.perform_actions!
    end
  end
  
end
