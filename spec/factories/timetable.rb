FactoryBot.define do
  factory(:timetable) do
    team { FactoryBot.create(:team) }
    route { FactoryBot.create(:route) }
  end
end
