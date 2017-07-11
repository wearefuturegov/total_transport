class Journey < ActiveRecord::Base
  belongs_to :route
  has_many :stops, through: :route
  has_many :outward_bookings, dependent: :destroy, class_name: 'Booking', foreign_key: 'journey_id'
  has_many :return_bookings, dependent: :destroy, class_name: 'Booking', foreign_key: 'return_journey_id'
  has_many :bookings, dependent: :destroy, class_name: 'Booking'
  belongs_to :vehicle
  belongs_to :supplier
  validates_presence_of :vehicle, :supplier, :start_time, :route

  scope :forwards, -> {where("reversed IS NOT TRUE")}
  scope :backwards, -> {where("reversed IS TRUE")}
  scope :available, -> {where('start_time > ? AND open_to_bookings IS TRUE', Time.now)}

  scope :past_or_future, ->(past_or_future) {
    if past_or_future == 'past'
      where('start_time < ?', Time.now).order('start_time DESC')
    elsif past_or_future == 'future'
      where('start_time > ?', Time.now).order('start_time ASC')
    end
  }
  
  scope :on_date, ->(date) {
    where('start_time >= ? AND start_time <= ?', Time.now.at_beginning_of_day, Time.now.at_end_of_day)
  }
  scope :booked_or_empty, ->(booked_or_empty) {
    if booked_or_empty == 'booked'
      joins(:outward_bookings).
      select('journeys.*').
      group('journeys.id').
      having('count(bookings.id) > 0')
    elsif booked_or_empty == 'empty'
      joins('LEFT OUTER JOIN bookings ON (bookings.journey_id = journeys.id OR bookings.return_journey_id = journeys.id)').
      select('journeys.*').
      group('journeys.id').
      having('count(bookings.id) = 0')
    end
  }

  filterrific(
    default_filter_params: {
      past_or_future: 'future'
    },
    available_filters: [
      :past_or_future,
      :on_date,
      :booked_or_empty
    ]
  )

  def booked_bookings
    bookings.booked
  end

  def editable_by_supplier?(supplier)
    supplier.team == self.supplier.team
  end

  def is_booked?
    bookings.count > 0
  end

  def seats_left
    vehicle.seats - booked_bookings.sum(:number_of_passengers)
  end

  def full?
    seats_left <= 0
  end

  def route_name
    if self.reversed?
      backwards_name
    else
      forwards_name
    end
  end

  def stops_in_direction
    if self.reversed?
      stops.reverse
    else
      stops
    end
  end

  def forwards_name
    "#{stops.first.name} - #{stops.last.name}"
  end

  def backwards_name
    "#{stops.last.name} - #{stops.first.name}"
  end

  def self.close_near_journeys
    number_of_hours_ahead = 6
    beginning_of_hour = Time.now.at_beginning_of_hour
    from_time = beginning_of_hour + number_of_hours_ahead.hours
    to_time = beginning_of_hour + number_of_hours_ahead.hours + 59.minutes
    where('start_time > ? AND start_time < ?', from_time, to_time).each do |journey|
      journey.update_attribute(:open_to_bookings, false)
    end
  end
end
