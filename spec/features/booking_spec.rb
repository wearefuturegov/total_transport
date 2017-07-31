require 'rails_helper'

feature 'User books journey', type: :feature, js: true do
  
  let!(:route) { FactoryGirl.create(:route) }
  let!(:outward_journey) { FactoryGirl.create(:journey, route: route, start_time: DateTime.now + 3.days) }
  let!(:return_journey) { FactoryGirl.create(:journey, route: route, reversed: true, start_time: outward_journey.start_time + 5.hours) }
  
  before(:each) do
    log_in_passenger
  end
  
  scenario 'Booking a return journey' do
    visit '/'

    choose_route(route)
    select_stops(route.stops.first.id, route.stops.last.id)
    choose_requirements(1, 0)
    choose_journey('outward', outward_journey.id)
    choose_journey('return', return_journey.id)
    set_location('pickup', route.stops.first.latitude, route.stops.first.longitude)
    set_location('dropoff', route.stops.last.latitude, route.stops.last.longitude)
    expect {
      click_button 'Pay with Cash'
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
    visit '/'

    choose_route(route)
    select_stops(route.stops.first.id, route.stops.last.id)
    choose_requirements(1, 0, true)
    choose_journey('outward', outward_journey.id)
    set_location('pickup', route.stops.first.latitude, route.stops.first.longitude)
    set_location('dropoff', route.stops.last.latitude, route.stops.last.longitude)
    expect {
      click_button 'Pay with Cash'
    }.to change { FakeSMS.messages.count }.by(1)
  end
  
  scenario 'Booking a journey with multiple passengers' do
    visit '/'

    choose_route(route)
    select_stops(route.stops.first.id, route.stops.last.id)
    choose_requirements(3, 0, false)
    choose_journey('outward', outward_journey.id)
    choose_journey('return', return_journey.id)
    set_location('pickup', route.stops.first.latitude, route.stops.first.longitude)
    set_location('dropoff', route.stops.last.latitude, route.stops.last.longitude)
    click_button 'Pay with Cash'
    expect(Booking.first.number_of_passengers).to eq(3)
  end
  
  scenario 'Booking a journey with child tickets' do
    visit '/'

    choose_route(route)
    select_stops(route.stops.first.id, route.stops.last.id)
    choose_requirements(2, 1, false)
    choose_journey('outward', outward_journey.id)
    choose_journey('return', return_journey.id)
    set_location('pickup', route.stops.first.latitude, route.stops.first.longitude)
    set_location('dropoff', route.stops.last.latitude, route.stops.last.longitude)
    click_button 'Pay with Cash'
    expect(Booking.first.number_of_passengers).to eq(2)
    expect(Booking.first.child_tickets).to eq(1)
  end
  
  private
  
    def log_in_passenger
      visit '/'
      first(:css, '#passenger_phone_number').set('+15005550006')
      first('input[value="Verify Number"]').click
      Passenger.last.verification_code.split('').each_with_index do |num, i|
        fill_in "digit#{i + 1}", with: num
      end
      click_button 'Verify'
    end
  
    def choose_requirements(number_of_passengers, child_tickets, single = false)
      first('#singleTab').click if single === true
      select(number_of_passengers, from: 'booking[number_of_passengers]')
      if child_tickets > 0
        first('#add-concession').click
        expect(page).to have_css('#concession-list')
        select 'Child fare', from: 'concession-list'
      end
      click_button 'Next'
    end
    
    def choose_route(route)
      find("a[href='#{new_route_booking_path(route, reversed: false)}']").click
    end
    
    def select_stops(pickup_stop_id, dropoff_stop_id)
      page.execute_script("$('#booking_dropoff_stop_id').val('#{dropoff_stop_id}')")
      page.execute_script("$('#booking_pickup_stop_id').val('#{pickup_stop_id}')")
      page.execute_script("$('#confirmationBtn').show()")
      click_button 'Confirm Route'
    end
    
    def choose_journey(type, journey_id)
      if type == 'return'
        selector = "booking_return_journey_id_#{journey_id}"
      else
        selector = "booking_journey_id_#{journey_id}"
      end
      first("label[for='#{selector}']").click
      click_button 'Next'
    end
    
    def set_location(type, lat, lng)
      page.execute_script("$('#booking_#{type}_lat').val('#{lat}')")
      page.execute_script("$('#booking_#{type}_lng').val('#{lng}')")
      page.execute_script("$('.disabled').attr('disabled', false)")
      click_button 'Next'
    end
  
end
