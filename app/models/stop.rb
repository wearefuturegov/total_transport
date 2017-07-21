class Stop < ActiveRecord::Base
  belongs_to :route
  acts_as_list scope: :route
  has_many :pickup_stops, class_name: 'Booking', foreign_key: 'pickup_stop_id', dependent: :destroy
  has_many :dropoff_stops, class_name: 'Booking', foreign_key: 'dropoff_stop_id', dependent: :destroy
  has_many :landmarks, dependent: :destroy
  has_many :suggested_edit_to_stops, dependent: :destroy

  validates_presence_of :route, :latitude, :longitude, :polygon

  def previous_stops(reversed = false)
    if reversed
      route.stops.where('position >= ?', self.position)
    else
      route.stops.where('position <= ?', self.position)
    end
  end

  def minutes_from_first_stop(reversed = false)
    m = 0
    previous_stops(reversed)[1..-1].each do |s|
      m += s.minutes_from_last_stop if s.minutes_from_last_stop
    end
    m
  end

  def time_for_journey(journey)
    journey.start_time + minutes_from_first_stop(journey.reversed?).minutes
  end

  def lat_lng
    Geokit::LatLng.new(self.latitude, self.longitude)
  end

  def distance_to(stop)
    self.lat_lng.distance_to(stop.lat_lng, units: :miles)
  end

  def position_in_order(reversed: false)
    if reversed
      route.stops.count - position + 1
    else
      position
    end
  end
end
