class CalculateMinutesFromLastStop < Que::Job

  def run(stop_id)
    stop = Stop.find(stop_id)
    ActiveRecord::Base.transaction do
      if stop.previous_stop && stop.minutes_from_last_stop.nil?
        stop.minutes_from_last_stop = DirectionsService.new([ from(stop), to(stop)]).total_duration
        stop.save
      end
    end
  end
  
  def from(stop)
    [stop.place.longitude, stop.place.latitude].join(',')
  end
  
  def to(stop)
    [
      stop.previous_stop.place.longitude,
      stop.previous_stop.place.latitude
    ].join(',')
  end

end
