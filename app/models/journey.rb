require 'csv'

class Journey < ActiveRecord::Base
  belongs_to :route
  has_many :stops, through: :route
  has_many :outward_bookings, dependent: :destroy, class_name: 'Booking', foreign_key: 'journey_id'
  has_many :return_bookings, dependent: :destroy, class_name: 'Booking', foreign_key: 'return_journey_id'
  has_many :bookings, dependent: :destroy, class_name: 'Booking'
  belongs_to :vehicle
  belongs_to :supplier
  validates_presence_of :vehicle, :supplier, :start_time, :route
  
  attr_accessor :pickup_stop, :dropoff_stop

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
    where('start_time >= ? AND start_time <= ?', date.at_beginning_of_day, date.at_end_of_day)
  }
  scope :booked_or_empty, ->(booked_or_empty) {
    where(booked: booked_or_empty == 'booked')
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
  
  after_create :close_before_end
  after_update :change_close_time, if: :start_time_changed?
  
  def self.available_for_places(start_place, destination_place)
    from = Stop.where(place: start_place)
    from_routes = from.map { |s| s.route }
    to = Stop.where(place: destination_place)
    to_routes = to.map { |s| s.route }
    (from_routes & to_routes).map do |route|
      f = from.find { |s| route.stops.include?(s) }
      t = to.find { |s| route.stops.include?(s) }
      Journey.available.where(
        route_id: route.id,
        reversed: f.position > t.position
      ).map do |j|
        j.pickup_stop = f
        j.dropoff_stop = t
        j
      end
    end.flatten.uniq
  end

  def booked_bookings
    bookings.booked
  end

  def editable_by_supplier?(supplier)
    supplier.team == self.supplier.team
  end

  def is_booked?
    all_bookings.count > 0
  end

  def seats_left
    vehicle.seats - booked_bookings.sum(:number_of_passengers)
  end

  def full?
    seats_left <= 0
  end

  def route_name
    "#{stops_in_direction.first.name} - #{stops_in_direction.last.name}"
  end

  def stops_in_direction
    reversed? ? stops.reverse : stops
  end
  
  def time_at_stop(stop)
    start_time + stop.minutes_from_first_stop(reversed?).minutes
  end
  
  def all_bookings
    outward_bookings.booked + return_bookings.booked
  end
  
  def csv
    CSV.generate do |csv|
      csv << csv_headers
      all_bookings.each do |booking|
        csv << booking.csv_row(self)
      end
    end
  end
  
  def csv_headers
    [
      'Date of travel',
      'Lead Passenger Name',
      'Mobile Number',
      'Email',
      'Number of Adults',
      'Number of Children',
      'Total Fare (including return element)',
      'Outbound or Return',
      'Pickup Time',
      'Pickup Place',
      'Pickup Location',
      'Dropoff Time',
      'Dropoff Place',
      'Dropoff Location',
      'Special Requirements',
      'Time and date booking made'
    ]
  end
  
  def filename
    [
      stops_in_direction.first.name.downcase,
      stops_in_direction.last.name.downcase,
      start_time.strftime('%F')
    ].join('-')
  end
  
  private
    
    def close_before_end
      CloseBeforeEnd.enqueue(id, run_at: start_time - 4.hours)
    end
    
    def change_close_time
      QueJob.where("args::json->>0 = '?' AND job_class = 'CloseBeforeEnd'", id).destroy_all
      close_before_end
    end

end
