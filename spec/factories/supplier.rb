FactoryGirl.define do
  factory(:supplier) do
    admin false
    approved false
    sequence(:email) { |n| "person#{n}@example.com" }
    password "password"
    password_confirmation "password"
    sequence(:name) { |n| "Supplier #{n}" }
    phone_number "07811407085"
  end
end
