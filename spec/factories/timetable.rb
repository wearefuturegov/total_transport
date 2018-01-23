FactoryBot.define do
  factory(:timetable) do
    vehicle { FactoryBot.create(:vehicle) }
    supplier { FactoryBot.create(:supplier) }
    route { FactoryBot.create(:route) }
  end
end
