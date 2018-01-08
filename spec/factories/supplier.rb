FactoryBot.define do
  sequence :email do |n|
    "person#{n}@example.com"
  end
end

FactoryBot.define do
  factory(:supplier) do
    admin false
    approved false
    email
    password "password"
    password_confirmation "password"
    name "James Darling"
    phone_number "07811407085"
  end
end
