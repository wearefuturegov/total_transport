FactoryBot.define do
  factory(:passenger) do
    name { FFaker::Name.name }
    phone_number '01632 960373'
    email { FFaker::Internet.email }
    verification_code '6579'
    verification_code_generated_at nil
  end
end
