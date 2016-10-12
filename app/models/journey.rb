class Journey < ActiveRecord::Base
  belongs_to :route
  has_many :stops, through: :route
  has_many :bookings, dependent: :destroy
  belongs_to :vehicle
  belongs_to :supplier
  validates_presence_of :vehicle, :supplier, :start_time, :route

  scope :forwards, -> {where("reversed IS NOT TRUE")}
  scope :backwards, -> {where("reversed IS TRUE")}
  scope :available, -> {where('start_time > ? AND open_to_bookings IS TRUE', Time.now)}

  def editable_by_supplier?(supplier)
    supplier.team == self.supplier.team
  end

  def is_booked?
    bookings.count > 0
  end

  def full?
    bookings.count >= vehicle.seats
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
