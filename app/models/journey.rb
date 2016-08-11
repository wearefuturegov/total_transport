class Journey < ActiveRecord::Base
  belongs_to :route
  has_many :stops, through: :route
  has_many :bookings, dependent: :destroy
  belongs_to :vehicle
  belongs_to :supplier
  validates_presence_of :vehicle, :supplier, :start_time, :route

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
