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
    
  private

  def journey_params
    {
      vehicle: timetable.vehicle,
      supplier: timetable.supplier,
      route: route,
      open_to_bookings: timetable.open_to_bookings,
      reversed: timetable.reversed
    }
  end
  
  def route
    if timetable.route.stops.count == stops.count
      timetable.route
    else
      Route.copy!(timetable.route.id, Stop.find(stops))
    end
  end
end
