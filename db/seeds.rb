Team.create!(name: 'Team 1')
Supplier.create!(email: "pezholio@gmail.com", password: "password", team_id: 1, name: "Me", phone_number: "132423", admin: true, approved: true)

DataSeed.create_places

route = FactoryGirl.create(:route, stops_count: 0)

FactoryGirl.create(:stop, position: 1,
  place: Place.find_by(name: 'Burnham-on-Crouch'),
  landmarks: [
    FactoryGirl.create(:landmark, name: 'Burnham-on-Crouch railway station', postcode: 'CM0 8DQ', stop: nil),
    FactoryGirl.create(:landmark, name: 'Dengie Hundred Sports Centre', postcode: 'CM0 8HS', stop: nil),
    FactoryGirl.create(:landmark, name: 'Eves Corner Bus Stop', postcode: 'CM0 8QE', stop: nil)
  ],
  route: route
)

FactoryGirl.create(:stop, position: 2,
  place: Place.find_by(name: 'Althorne'),
  landmarks: [
    FactoryGirl.create(:landmark, name: 'Three Horseshoes Pub', postcode: 'CM3 6DP', stop: nil),
    FactoryGirl.create(:landmark, name: 'Althorne Train Station', postcode: 'CM3 6DG', stop: nil),
    FactoryGirl.create(:landmark, name: 'Fords Corner Bus Stop', postcode: 'CM3 6DP', stop: nil)
  ],
  route: route
)

FactoryGirl.create(:stop, position: 3,
  place: Place.find_by(name: 'North Fambridge'),
  landmarks: [
    FactoryGirl.create(:landmark, name: 'North Fambridge Station', postcode: 'CM3 6NB', stop: nil)
  ],
  route: route
)

FactoryGirl.create(:stop, position: 4,
  place: Place.find_by(name: 'Cold Norton'),
  landmarks: [
    FactoryGirl.create(:landmark, name: 'The Norton Pub', postcode: 'CM3 6JB', stop: nil),
    FactoryGirl.create(:landmark, name: 'Cold Norton Primary School', postcode: 'CM3 6JE', stop: nil)
  ],
  route: route
)

FactoryGirl.create(:stop, position: 5,
  place: Place.find_by(name: 'Stow Maries'),
  landmarks: [
    FactoryGirl.create(:landmark, name: 'Prince Of Wales Pub', postcode: 'CM3 6SA', stop: nil)
  ],
  route: route
)

FactoryGirl.create(:stop, position: 6,
  place: Place.find_by(name: 'South Woodham Ferrers'),
  landmarks: [
    FactoryGirl.create(:landmark, name: 'South Woodham Ferrers Station', postcode: 'CM3 5NQ', stop: nil),
    FactoryGirl.create(:landmark, name: 'Marsh Farm', postcode: 'CM3 5WP', stop: nil)
  ],
  route: route
)

FactoryGirl.create(:vehicle, team_id: 1, seats: 12, registration: "MJ57FCP", make_model: "Mercedes Benz Sprinter Minibus", colour: "Silver")

DataSeed.create_journeys
