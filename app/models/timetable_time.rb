class TimetableTime < ApplicationRecord
  belongs_to :timetable
  belongs_to :route
  has_many :journeys, dependent: :destroy
  
  attr_accessor :stops
  
  def create_journey(start_time)
    journeys.create(journey_params.merge({start_time: start_time}))
  end
  
  def stops
    @stops || timetable.route.stops
  end
  
  def route
    journeys.first&.route
  end
    
  private

  def journey_params
    {
      seats: seats,
      team: timetable.team,
      route: get_route,
      open_to_bookings: timetable.open_to_bookings,
      reversed: timetable.reversed
    }
  end
  
  def get_route
    if timetable.route.stops.count == stops.count
      timetable.route
    elsif route.nil?
      setup_route
    else
      self.route
    end
  end
  
  def setup_route
    route = Route.copy!(timetable.route.id, Stop.find(stops))
    save
    route
  end
end
