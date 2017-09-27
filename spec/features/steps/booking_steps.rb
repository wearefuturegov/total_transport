step 'my booking should be confirmed' do
  expect(Booking.count).to eq(1)
  @booking = Booking.first
  expect(@booking.state).to eq('booked')
end

step 'my booking should be a single journey' do
  expect(@booking.return_journey_id).to be_nil
end

step 'my booking should be confirmed' do
  expect(Booking.count).to eq(1)
  @booking = Booking.first
  expect(@booking.state).to eq('booked')
end

step 'my booking should be a single journey' do
  expect(@booking.return_journey_id).to be_nil
end

step 'my booking should have :n passenger(s)' do |n|
  expect(@booking.number_of_passengers).to eq(n.to_i)
end

step 'my booking should have :n child ticket(s)' do |n|
  expect(@booking.child_tickets).to eq(n.to_i)
end
