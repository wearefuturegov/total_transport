step 'I have an invalid card' do
  expect(Stripe::Charge).to receive(:create).and_raise(Stripe::CardError.new('The card was declined', nil, nil))
end

step 'I should see an error saying my card has been declined' do
  expect(page).to have_content('There was a problem with your card')
end
