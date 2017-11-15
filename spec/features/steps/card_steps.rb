step 'I have an invalid card' do
  expect_any_instance_of(Booking).to receive(:create_payment!).and_raise(Stripe::CardError.new('The card was declined', nil, nil))
end

step 'I should see an error saying my card has been declined' do
  expect(page).to have_content('There was a problem with your card')
end
