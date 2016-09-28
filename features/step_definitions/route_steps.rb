Given(/^the Sudbury to Saffron Walden route exists$/) do
  @route = FactoryGirl.create(:route)
  FactoryGirl.create(:stop, route: @route, name: "Sudbury")
  FactoryGirl.create(:stop, route: @route, name: "Halstead", minutes_from_last_stop: 4)
  FactoryGirl.create(:stop, route: @route, name: "Haverhill", minutes_from_last_stop: 7)
  FactoryGirl.create(:stop, route: @route, name: "Saffron Walden", minutes_from_last_stop: 9)
end

Given(/^the route has a journey at (\d+)pm tomorrow$/) do |arg1|
  @supplier ||= FactoryGirl.create(:supplier)
  @team ||= @supplier.team
  @vehicle ||= FactoryGirl.create(:vehicle, team: @team)
  FactoryGirl.create(:journey,
    route: @route,
    start_time: Date.tomorrow + 18.hours,
    supplier: @supplier,
    vehicle: @vehicle
  )
end

When(/^I follow "([^"]*)" for the route$/) do |arg1|
  find(:css, ".route a").trigger('click')
end
