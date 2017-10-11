module WebSteps
  step 'I visit /journeys' do
    visit '/journeys'
  end

  step :choose_place, 'I choose a :text_field point of :place'
  step :choose_passengers, 'I choose :num passengers'
  step :click_request_one_way_or_return, 'I click on the first journey\'s request button'
  step :choose_first_return_journey, 'I choose the first return option'
  step :choose_single_journey, 'I don\'t choose a return journey'
  step :click_next, 'I don\'t add any special requirements'
  step :enter_first_passengers_confirmation_code, 'I enter my confirmation code'
  step :choose_child_tickets, 'I choose :n child ticket(s)'

  step 'I should see :n journey(s)' do |n|
    expect(page).to have_css('.options form.new_booking', :count => n)
  end

  step 'I have chosen a journey' do
    choose_place('from', 'Newmarket')
    choose_place('to', 'Haverhill')
    click_request_one_way_or_return
  end

  step 'I have chosen a journey with :n passengers' do |passengers|
    choose_place('from', 'Newmarket')
    choose_place('to', 'Haverhill')
    choose_passengers(passengers)
    click_request_one_way_or_return
  end

  step 'I choose a pickup and dropoff point' do
    choose_pickup_dropoff_point('pickup', @route.stops.first.place.latitude, @route.stops.first.place.longitude)
    choose_pickup_dropoff_point('dropoff', @route.stops.last.place.latitude, @route.stops.last.place.longitude)
  end

  step 'I fill in my details' do
    fill_in_details('My Name', '+15005550006')
  end
  
  step 'I should see the message' do |message|
    wait_for_ajax
    expect(page).to have_content(message)
  end
  
  step 'I should see a suggestion of a journey from :start_point to :destination' do |start_point, destination|
    wait_for_ajax
    expect(body).to match("#{start_point} to #{destination}")
  end
  
  def choose_place(field, place)
    fill_in field, with: place
    wait_for_ajax
    first('.easy-autocomplete-container li', text: /#{place}/).click
  end

  def click_request_one_way_or_return
    click_button 'Request one way or return'
  end

  def choose_passengers(num)
    select(num, from: 'booking[number_of_passengers]')
  end

  def choose_first_return_journey
    find('#returnTab').click
    first('label').click
    click_next
  end

  def choose_single_journey
    find('#singleTab').click
    click_next
  end

  def choose_pickup_dropoff_point(type, lat, lng)
    page.execute_script("$('#booking_#{type}_lat').val('#{lat}')")
    page.execute_script("$('#booking_#{type}_lng').val('#{lng}')")
    page.execute_script("$('.disabled').attr('disabled', false)")
    wait_for_ajax
    click_next
  end

  def fill_in_details(first_name, phone_numer)
    fill_in 'booking_passenger_name', with: first_name
    fill_in 'booking_phone_number', with: phone_numer
    click_button 'Confirm phone number'
  end

  def click_next
    click_button 'Next'
  end

  def enter_confirmation_code(code)
    code.split('').each_with_index do |num, i|
      fill_in "digit#{i + 1}", with: num
    end
    click_button 'Verify'
  end

  def enter_first_passengers_confirmation_code
    enter_confirmation_code(Passenger.last.verification_code)
  end

  def choose_child_tickets(num)
    num.to_i.times do |n|
      first('#add-concession').click
      expect(page).to have_css('#concession-list')
      select 'Child fare', from: 'concession-list'
    end
    click_button 'Next'
  end

end

placeholder :text_field do
  match /(from|to)/ do |element|
    element
  end
end

placeholder :outward_or_return do
  match /(outward|return)/ do |direction|
    direction == 'return'
  end
end

RSpec.configure do |config|
  config.include WebSteps, type: :feature
end
