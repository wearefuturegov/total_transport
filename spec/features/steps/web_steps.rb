module WebSteps
  step 'I visit /journeys' do
    visit '/journeys'
  end

  step :choose_place, 'I choose a :text_field point of :place'
  step :choose_passengers, 'I choose :num :type passenger(s)'
  step :click_book_journey, 'I click the book journey button'
  step :choose_single_journey, 'I don\'t choose a return journey'
  step :choose_child_tickets, 'I choose :n child ticket(s)'
  step :choose_journey, 'I choose a journey'
  step :choose_pickup_and_dropoff_point, 'I choose a pickup and dropoff point'
  
  step 'I have entered my booking details' do
    choose_place('from', 'Newmarket')
    choose_place('to', 'Haverhill')
    click_book_journey
    choose_journey
    choose_pickup_and_dropoff_point
    fill_in_details('My Name', '+15005550006')
  end

  step 'I have chosen a journey' do
    choose_place('from', 'Newmarket')
    choose_place('to', 'Haverhill')
    click_book_journey
    choose_journey
    choose_pickup_and_dropoff_point
  end
  
  step 'I have chosen a single journey' do
    choose_place('from', 'Newmarket')
    choose_place('to', 'Haverhill')
    click_book_journey
    choose_single_journey
    choose_pickup_and_dropoff_point
  end

  step 'I have chosen a journey with :n passengers' do |passengers|
    choose_place('from', 'Newmarket')
    choose_place('to', 'Haverhill')
    choose_passengers(passengers)
    click_book_journey
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
    expect(first('.suggestion').value).to eq(destination)
  end
  
  step 'I confirm my booking' do
    page.execute_script '$("#submit-booking")[0].scrollIntoView(true)'
    click_button I18n.t('helpers.submit.booking.update')
  end
  
  step 'I choose :num ":type" bus pass(es)' do |num, type|
    page.execute_script 'document.getElementById(\'add-pass\').scrollIntoView(true)'
    click_on 'add-pass'
    case type
    when 'older people\'s'
      select 'Older Persons Bus Pass', from: 'pass'
    when 'disabled'
      select 'Disabled Bus Pass', from: 'pass'
    end
    select num, from: 'pass_number'
  end
  
  step 'I remove the bus pass' do
    first('button.remove').click
  end
  
  step 'I should see the price for :num adult passengers' do |n|
    price = Booking.last.adult_return_price
    expect(page).to have_content "#{n} x adult ticket"
    expect(page).to have_content (price * n.to_i).to_s
  end
  
  step 'I should see ":message"' do |message|
    expect(page).to have_content message
  end
  
  step 'I should not be able to choose another ":type" bus pass' do |type|
    type = case type
    when 'older people\'s'
      'older_bus_passes'
    when 'disabled'
      'disabled_bus_passes'
    end
    click_on 'add-pass'
    expect(all('.pass-type').last.all("option[value='#{type}']").count).to eq(0)
  end
  
  step 'I choose the outward journey' do
    choose_place('from', 'Newmarket')
    choose_place('to', 'Haverhill')
    click_book_journey
    first('.date-button').click
    find(:xpath, "//input[@value='#{@false_journey.id}']/.//..").click
  end
  
  step 'I should not see the return journey' do
    expect(page).to have_no_selector(:xpath, "//input[@value='#{@true_journey.id}']/.//..")
  end
  
  step 'I should see a message telling me there are no return journeys available' do
    expect(page).to have_content(I18n.t('bookings.no_return_time'))
  end
  
  step 'I pay via online payments' do
    page.execute_script '$("#pay-online")[0].scrollIntoView(true)'
    click_on I18n.t('button.pay')
    within_frame 'stripe_checkout_app' do
      find_field('Email').send_keys 'someone@wearefuturegov.com'
      find_field('Card number').send_keys '4242424242424242'
      find_field('MM / YY').send_keys "01#{DateTime.now.year + 1}"
      find_field('CVC').send_keys '123'
      find_field('ZIP Code').send_keys 'SW1A1AA'
      find('button[type="submit"]').click
      sleep 5
    end
  end
  
  step 'I should see the confirmation page' do
    expect(page).to have_content('your Ride is now confirmed')
  end
  
  def click_book_journey
    wait_for_ajax
    click_button I18n.t('button.book')
  end
  
  def choose_journey
    first('.date-button').click
    first('#outward_times .time label').click
    wait_for_ajax
    first('#return_times .time label').click
  end
  
  def choose_single_journey
    first('.date-button').click
    first('#outward_times label.button').click
    find('label', text: /#{I18n.t('button.oneway')}/i).click
  end
  
  def choose_place(field, place)
    fill_in field, with: place
    wait_for_ajax
    first('.easy-autocomplete-container li', text: /#{place}/).click
  end

  def choose_passengers(num, type)
    num = num.to_i
    selector = case type
    when 'adult'
      num = num - 1
      'booking_number_of_adults'
    when 'child'
      'booking_child_tickets'
    when 'bus pass'
      'booking_older_bus_passes'
    end
    num.times do
      page.execute_script("$('##{selector}').next('.inc').click()")
    end
  end
  
  def choose_pickup_and_dropoff_point
    choose_pickup_dropoff_point('pickup', @route.stops.first.landmarks.first)
    choose_pickup_dropoff_point('dropoff', @route.stops.last.landmarks.first)
  end

  def choose_pickup_dropoff_point(type, landmark)
    select(landmark.name, from: "booking_#{type}_landmark_id")
  end

  def fill_in_details(first_name, phone_numer)
    fill_in 'booking_passenger_name', with: first_name
    fill_in 'booking_phone_number', with: phone_numer
    page.execute_script 'document.getElementById(\'submit-booking\').scrollIntoView(true)'
    click_button I18n.t('button.next')
  end

  def choose_child_tickets(num)
    page.execute_script 'document.getElementById(\'add-concession\').scrollIntoView(true)'
    num.to_i.times do |n|
      first('#add-concession').click
      expect(page).to have_css('#concession-list')
      select 'Child fare', from: 'concession-list'
    end
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
