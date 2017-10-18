module WebSteps
  step 'I visit /journeys' do
    visit '/journeys'
  end

  step :choose_place, 'I choose a :text_field point of :place'
  step :choose_passengers, 'I choose :num passengers'
  step :click_book_journey, 'I click the book journey button'
  step :choose_single_journey, 'I don\'t choose a return journey'
  step :choose_child_tickets, 'I choose :n child ticket(s)'
  step :choose_journey, 'I choose a journey'
  step :choose_pickup_and_dropoff_point, 'I choose a pickup and dropoff point'

  step 'I have chosen a journey' do
    choose_place('from', 'Newmarket')
    choose_place('to', 'Haverhill')
    click_book_journey
    choose_journey
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
    expect(body).to match("#{start_point} to #{destination}")
  end
  
  def click_book_journey
    wait_for_ajax
    click_button 'Book Journey'
  end
  
  def choose_journey
    first('.date-button').click
    first('#outward_times input').click
    all('#return_times input')[1].click
  end
  
  def choose_place(field, place)
    fill_in field, with: place
    wait_for_ajax
    first('.easy-autocomplete-container li', text: /#{place}/).click
  end

  def choose_passengers(num)
    select(num, from: 'booking[number_of_passengers]')
  end

  def choose_single_journey
    first('#return_times input').click
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
    click_button 'Submit your booking request'
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
