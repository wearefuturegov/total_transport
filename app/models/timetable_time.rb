class TimetableTime < ActiveRecord::Base
  belongs_to :timetable
  has_many :journeys
  
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
      supplier: timetable.supplier,
      route: get_route,
      open_to_bookings: timetable.open_to_bookings,
      reversed: timetable.reversed
    }
  end
  
  def get_route
    if timetable.route.stops.count == stops.count
      timetable.route
    else
      if route.nil?
        route = Route.copy!(timetable.route.id, Stop.find(stops))
        save
      end
      route
    end
  end
end
