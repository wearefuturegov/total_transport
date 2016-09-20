When(/^I submit the correct verification code$/) do
  verification_code = Passenger.last.verification_code
  fill_in('verification_code', with: verification_code)
  click_button("Go")
end
