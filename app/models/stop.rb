class Stop < ActiveRecord::Base
  belongs_to :route
  acts_as_list scope: :route

  def previous_stops
    route.stops.where('position <= ?', self.position)
  end

  def minutes_from_first_stop
    m = 0
    previous_stops.each {|s| m += s.minutes_from_last_stop}
    m
  end

  def time_for_journey(journey)
    journey.start_time + minutes_from_first_stop.minutes
  end

  def minutes_from_last_stop
    if position == 0
      0
    else
      super
    end
  end
end
