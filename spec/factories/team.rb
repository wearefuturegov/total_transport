FactoryBot.define do
  factory(:team) do
    name nil
    email 'hello@example.com'
    suppliers { FactoryBot.create_list(:supplier, 2) }
  end
end
