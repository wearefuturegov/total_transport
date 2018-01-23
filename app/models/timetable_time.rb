class TimetableTime < ActiveRecord::Base
  belongs_to :timetable
  has_many :journeys
  
  def create_journey(start_time)
    journeys.create(journey_params.merge({start_time: start_time}))
  end
    
  private

  def journey_params
    {
      vehicle: timetable.vehicle,
      supplier: timetable.supplier,
      route: timetable.route
    }
  end
end
