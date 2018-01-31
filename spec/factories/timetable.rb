FactoryBot.define do
  factory(:timetable) do
    supplier { FactoryBot.create(:supplier) }
    route { FactoryBot.create(:route) }
  end
end
