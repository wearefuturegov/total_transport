FactoryBot.define do
  factory(:vehicle) do
    colour "Red"
    make_model "Supermodel"
    registration "12121"
    seats 6
    team
  end
end
