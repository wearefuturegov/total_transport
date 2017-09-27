step 'I visit /journeys' do
  visit '/journeys'
end

step 'I choose a :text_field point of :point' do |text_field, point|
  fill_in text_field, with: point
  wait_for_ajax
  find('.easy-autocomplete-container li').click
end

step 'I click See available journeys' do
  find('#submit').click
end

step 'I should see :n journey(s)' do |n|
  expect(page).to have_css('.options form.new_booking', :count => n)
end

step 'I have chosen a journey' do
  [
    'I choose a from point of Newmarket',
    'I choose a to point of Haverhill',
    'I click See available journeys'
  ].each { |s| step s }
  click_button 'Request one way or return'
end

step 'I have chosen a journey with :n passengers' do |passengers|
  [
    'I choose a from point of Newmarket',
    'I choose a to point of Haverhill',
    'I click See available journeys'
  ].each { |s| step s }
  send 'I choose :num passengers', passengers
  click_button 'Request one way or return'
end

step 'I click on the first journey\'s request button' do
  click_button 'Request one way or return'
end

step 'I choose the first return option' do
  find('#returnTab').click
  first('label').click
  click_button 'Next'
end

step 'I don\'t choose a return journey' do
  find('#singleTab').click
  click_button 'Next'
end

step 'I don\'t add any special requirements' do
  click_button 'Next'
end

step 'I choose a pickup and dropoff point' do
  send 'I choose a :type point of :lat and :lng', 'pickup', @route.stops.first.place.latitude, @route.stops.first.place.longitude
  send 'I choose a :type point of :lat and :lng', 'dropoff', @route.stops.last.place.latitude, @route.stops.last.place.longitude
end

step 'I choose a :type point of :lat and :lng' do |type, lat, lng|
  page.execute_script("$('#booking_#{type}_lat').val('#{lat}')")
  page.execute_script("$('#booking_#{type}_lng').val('#{lng}')")
  page.execute_script("$('.disabled').attr('disabled', false)")
  wait_for_ajax
  click_button 'Next'
end

step 'I fill in my details' do
  fill_in 'booking_passenger_name', with: 'My Name'
  fill_in 'booking_phone_number', with: '+15005550006'
  click_button 'Confirm phone number'
end

step 'I enter my confirmation code' do
  Passenger.last.verification_code.split('').each_with_index do |num, i|
    fill_in "digit#{i + 1}", with: num
  end
  click_button 'Verify'
end

step 'I choose :num passengers' do |num|
  select(num, from: 'booking[number_of_passengers]')
end

step 'I choose :n child ticket(s)' do |num|
  num.to_i.times do |n|
    first('#add-concession').click
    expect(page).to have_css('#concession-list')
    select 'Child fare', from: 'concession-list'
  end
  click_button 'Next'
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
