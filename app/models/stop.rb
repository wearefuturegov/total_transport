class Stop < ActiveRecord::Base
  belongs_to :route
  acts_as_list scope: :route

  def previous_stops
    route.stops.where('position <= ?', self.position)
  end

  def minutes_from_first_stop
    m = 0
    previous_stops[1..-1].each do |s|
      m += s.minutes_from_last_stop if s.minutes_from_last_stop
    end
    m
  end

  def time_for_journey(journey)
    journey.start_time + minutes_from_first_stop.minutes
  end
end
