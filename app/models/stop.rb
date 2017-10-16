class Stop < ActiveRecord::Base
  belongs_to :route
  belongs_to :place
  acts_as_list scope: :route
  has_many :pickup_stops, class_name: 'Booking', foreign_key: 'pickup_stop_id', dependent: :destroy
  has_many :dropoff_stops, class_name: 'Booking', foreign_key: 'dropoff_stop_id', dependent: :destroy
  has_many :landmarks, dependent: :destroy
  has_many :suggested_edit_to_stops, dependent: :destroy
  
  accepts_nested_attributes_for :landmarks, reject_if: :all_blank, allow_destroy: true

  validates_presence_of :place, :route
  validate :check_landmarks
  
  after_create :queue_minutes_from_last_stop

  def previous_stops(reversed = false)
    if reversed
      route.stops.where('position >= ?', position)
    else
      route.stops.where('position <= ?', position)
    end
  end
  
  def previous_stop(reversed = false)
    if reversed
      route.stops.find_by(position: position + 1)
    else
      route.stops.find_by(position: position - 1)
    end
  end

  def minutes_from_first_stop(reversed = false)
    previous_stops(reversed).drop(1).sum { |s| s.try(:minutes_from_last_stop) || 0 }
  end

  def distance_to(stop)
    place.lat_lng.distance_to(stop.place.lat_lng, units: :miles)
  end
  
  def name
    place.name
  end

  def position_in_order(reversed: false)
    if reversed
      route.stops.count - position + 1
    else
      position
    end
  end
  
  def queue_minutes_from_last_stop
    CalculateMinutesFromLastStop.enqueue(id)
  end
  
  def check_landmarks
    if landmarks.size == 0
      self.errors.add :landmarks, 'You must specify at least one landmark'
    end
  end
  
end
