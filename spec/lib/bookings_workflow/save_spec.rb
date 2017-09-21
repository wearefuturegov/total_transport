require 'rails_helper'

RSpec.describe BookingsWorkflow::Save, type: :model do
  include Rails.application.routes.url_helpers

  let(:route) { FactoryGirl.create(:route) }
  let(:booking) { FactoryGirl.create(:booking) }
  let(:journey) { FactoryGirl.create(:journey) }
  let(:return_journey) { FactoryGirl.create(:journey) }
  let(:session) { Hash.new }
  let(:subject) { BookingsWorkflow::Save.new(step, route, booking, params, session) }
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
      return_journey_id: return_journey.id,
      pickup_lat: 52.4323,
      pickup_lng: -1.4234,
      pickup_name: 'Somewhere',
      dropoff_lat: 52.4323,
      dropoff_lng: -1.4234,
      dropoff_name: 'Somewhere',
      passenger_name: 'Me',
      phone_number: '+15005550006',
      payment_method: 'cash',
      verification_code: '1234'
    })
  }
    
  context 'if the step is not present in the steps constant' do
    let(:step) { :make_cake }
    
    it 'errors' do
      expect { subject }.to raise_error("Invalid step key!")
    end
  end
  
  context 'with return_journey step' do
    let(:step) { :return_journey }
    
    it 'returns the correct redirect path' do
      expect(subject.redirect_path).to eq(edit_requirements_route_booking_path(route, booking))
    end
    
    it 'returns the correct params' do
      expect(subject.params).to eq(ActionController::Parameters.new({
        return_journey_id: return_journey.id
      }))
    end
    
    it 'updates the correct atttributes' do
      subject.perform_actions!
      subject.params.each do |k,v|
        expect(booking.send(k)).to eq(v)
      end
    end
  end
  
  context 'with requirements step' do
    let(:step) { :requirements }
    
    it 'returns the correct redirect path' do
      expect(subject.redirect_path).to eq(edit_pickup_location_route_booking_path(route, booking))
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
      expect(subject.redirect_path).to eq(edit_verify_route_booking_path(route, booking))
    end
    
    it 'returns the correct params' do
      expect(subject.params).to eq(ActionController::Parameters.new({
        passenger_name: 'Me',
        phone_number: '+15005550006',
        payment_method: 'cash'
      }))
    end
    
    it 'updates the correct atttributes' do
      subject.perform_actions!
      subject.params.each do |k,v|
        expect(booking.send(k)).to eq(v)
      end
    end
    
    it 'sends a verification code' do
      expect { subject.perform_actions! }.to change { FakeSMS.messages.count }.by(1)
      expect(FakeSMS.messages.last[:to]).to eq(booking.phone_number)
    end
    
    it 'creates a passenger' do
      subject.perform_actions!
      expect(booking.passenger).to_not be_nil
    end

  end
  
  context 'with verify step' do
    before { booking.passenger = FactoryGirl.create(:passenger, verification_code: '1234')}
    let(:step) { :verify }
    
    it 'returns the correct redirect path' do
      subject.perform_actions!
      expect(subject.redirect_path).to eq(confirmation_route_booking_path(route, booking))
    end
    
    it 'sends a confirmation' do
      expect(booking).to receive(:confirm!)
      subject.perform_actions!
    end
    
    context 'with invalid verification_code' do
      before { booking.passenger = FactoryGirl.create(:passenger, verification_code: '2345')}
      
      it 'returns the correct redirect path' do
        subject.perform_actions!
        expect(subject.redirect_path).to eq(edit_verify_route_booking_path(route, booking))
      end
      
      it 'returns an alert' do
        subject.perform_actions!
        expect(subject.flash_alert).to eq('Phone number is not valid, please try another one')
      end
    end

  end
  
end
