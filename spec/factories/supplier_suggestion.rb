FactoryBot.define do
  factory(:supplier_suggestion) do
    description "TESTY"
    supplier
    url "http://total-transport.herokuapp.com/admin"
  end
end
