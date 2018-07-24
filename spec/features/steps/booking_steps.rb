step 'my booking should be confirmed' do
  expect(Booking.count).to eq(1)
  @booking = Booking.first
  expect(@booking.state).to eq('booked')
end

step 'my booking should not be confirmed' do
  @booking = Booking.first
  expect(@booking.state).to_not eq('booked')
end

step 'my booking should be a single journey' do
  expect(@booking.return_journey_id).to eq(0)
end

step 'my booking should have :n passenger(s)' do |n|
  expect(@booking.number_of_passengers).to eq(n.to_i)
end

step 'my booking should have :n child ticket(s)' do |n|
  expect(@booking.child_tickets).to eq(n.to_i)
end

step 'my booking should have :n ":type" bus pass(es)' do |n, type|
  case type
  when 'Older People\'s'
    expect(@booking.older_bus_passes).to eq(n.to_i)
  when 'Disabled'
    expect(@booking.disabled_bus_passes).to eq(n.to_i)
  end
end

step 'my contact details should be saved' do
  expect(@booking.passenger).to_not be_nil
  expect(@booking.passenger.name).to eq(@first_name)
  expect(@booking.passenger.phone_number).to eq(@phone_number)
end

step 'my booking should have a charge id' do
  expect(@booking.charge_id).to_not be_nil
end

step 'my payment method should be :type' do |type|
  expect(@booking.payment_method).to eq(type)
end

step 'both journeys should show as booked' do
  expect(@booking.journey.booked).to eq(true)
  expect(@booking.journey.all_bookings.count).to eq(1)
  expect(@booking.return_journey.booked).to eq(true)
  expect(@booking.return_journey.all_bookings.count).to eq(1)
end
