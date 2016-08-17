FactoryGirl.define do
  factory(:supplier) do
    admin false
    approved false
    email "james@abscond.org"
    password "password"
    password_confirmation "password"
    name "James Darling"
    phone_number "07811407085"
  end
end
