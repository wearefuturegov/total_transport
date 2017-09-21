require 'rails_helper'

feature 'User books journey', type: :feature, js: true do
  
  let!(:route) { FactoryGirl.create(:route) }
  let!(:outward_journey) { FactoryGirl.create(:journey, route: route, reversed: false, start_time: DateTime.now + 3.days) }
  let!(:return_journey) { FactoryGirl.create(:journey, route: route, reversed: true, start_time: outward_journey.start_time + 5.hours) }
  
  before(:each) do
    visit journeys_path
  end
  
  scenario 'Booking a return journey' do
    choose_journey(route.stops.first.place, route.stops.last.place, 1)
    choose_return_journey(return_journey.id)
    choose_requirements(0)
    set_location('pickup', route.stops.first.place.latitude, route.stops.first.place.longitude)
    set_location('dropoff', route.stops.last.place.latitude, route.stops.last.place.longitude)
    fill_details('My Name', '+15005550006')
    expect {
     click_button 'Confirm phone number'
    }.to change { FakeSMS.messages.count }.by(1)
    
    expect {
     enter_verification_code(Passenger.last.verification_code)
    }.to change { FakeSMS.messages.count }.by(1)
    
    expect(Booking.count).to eq(1)
    booking = Booking.first
    expect(booking.journey).to eq(outward_journey)
    expect(booking.return_journey).to eq(return_journey)
    expect(booking.pickup_stop_id).to eq(route.stops.first.id)
    expect(booking.dropoff_stop_id).to eq(route.stops.last.id)
    expect(booking.state).to eq('booked')
  end
  
  scenario 'Booking a single journey' do
    choose_journey(route.stops.first.place, route.stops.last.place, 1)
    choose_single_journey
    choose_requirements(0)
    set_location('pickup', route.stops.first.place.latitude, route.stops.first.place.longitude)
    set_location('dropoff', route.stops.last.place.latitude, route.stops.last.place.longitude)
    expect {
      click_button 'Confirm phone number'
    }.to change { FakeSMS.messages.count }.by(1)
    
    expect {
      enter_verification_code(Passenger.last.verification_code)
    }.to change { FakeSMS.messages.count }.by(1)
  end
  
  scenario 'Booking a journey with multiple passengers' do
    choose_journey(route.stops.first.place, route.stops.last.place, 3)
    choose_return_journey(return_journey.id)
    choose_requirements(0)
    set_location('pickup', route.stops.first.place.latitude, route.stops.first.place.longitude)
    set_location('dropoff', route.stops.last.place.latitude, route.stops.last.place.longitude)
    click_button 'Confirm phone number'
    enter_verification_code(Passenger.last.verification_code)
    expect(Booking.first.number_of_passengers).to eq(3)
  end
  
  scenario 'Booking a journey with child tickets' do
    choose_journey(route.stops.first.place, route.stops.last.place, 2)
    choose_return_journey(return_journey.id)
    choose_requirements(1)
    set_location('pickup', route.stops.first.place.latitude, route.stops.first.place.longitude)
    set_location('dropoff', route.stops.last.place.latitude, route.stops.last.place.longitude)
    click_button 'Confirm phone number'
    enter_verification_code(Passenger.last.verification_code)
    expect(Booking.first.number_of_passengers).to eq(2)
    expect(Booking.first.child_tickets).to eq(1)
  end
  
  private
  
    def choose_journey(from, to, number_of_passengers = 1)
      choose_from(from)
      choose_to(to)
      click_button 'See available journeys'
      select(number_of_passengers, from: 'booking[number_of_passengers]')
      click_button 'Request one way or return'
    end
  
    def choose_from(place)
      fill_in 'from', with: place.name
      wait_for_ajax
      first('.easy-autocomplete-container li').click
    end
    
    def choose_to(place)
      fill_in 'to', with: place.name
      wait_for_ajax
      first('.easy-autocomplete-container li').click
    end
  
    def choose_requirements(child_tickets)
      if child_tickets > 0
        first('#add-concession').click
        expect(page).to have_css('#concession-list')
        select 'Child fare', from: 'concession-list'
      end
      click_button 'Next'
    end
    
    def select_stops(pickup_stop_id, dropoff_stop_id)
      page.execute_script("$('#booking_dropoff_stop_id').val('#{dropoff_stop_id}')")
      page.execute_script("$('#booking_pickup_stop_id').val('#{pickup_stop_id}')")
      page.execute_script("$('#confirmationBtn').show()")
      click_button 'Confirm Route'
    end
    
    def choose_return_journey(journey_id)
      find('#returnTab').click
      selector = "booking_return_journey_id_#{journey_id}"
      first("label[for='#{selector}']").click
      click_button 'Next'
    end
    
    def choose_single_journey
      find('#singleTab').click
      click_button 'Next'
    end
    
    def set_location(type, lat, lng)
      page.execute_script("$('#booking_#{type}_lat').val('#{lat}')")
      page.execute_script("$('#booking_#{type}_lng').val('#{lng}')")
      page.execute_script("$('.disabled').attr('disabled', false)")
      click_button 'Next'
    end
    
    def fill_details(name, phone_number)
      fill_in 'booking_passenger_name', with: name
      fill_in 'booking_phone_number', with: phone_number
    end
    
    def enter_verification_code(code)
      code.split('').each_with_index do |num, i|
        fill_in "digit#{i + 1}", with: num
      end
      click_button 'Verify'
    end
  
end
