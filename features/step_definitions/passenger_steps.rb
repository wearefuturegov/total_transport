When(/^I submit the correct verification code$/) do
  verification_code = Passenger.last.verification_code
  fill_in('verification_code', with: verification_code)
  click_button("Verify")
end

When(/^I submit an incorrect verification code$/) do
  fill_in('verification_code', with: 'xxx')
  click_button("Verify")
end

Given(/^I am logged in$/) do
  @current_passenger = FactoryGirl.create(:passenger)
  cookies[:stub_user_id] = @current_passenger.id
  page.driver.browser.clear_cookies
  page.driver.browser.set_cookie("stub_user_id=#{@current_passenger.id}; path=/; domain=127.0.0.1")
end
