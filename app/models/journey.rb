require 'csv'

class Journey < ApplicationRecord
  belongs_to :route
  has_many :stops, through: :route
  has_many :outward_bookings, dependent: :destroy, class_name: 'Booking', foreign_key: 'journey_id'
  has_many :return_bookings, dependent: :destroy, class_name: 'Booking', foreign_key: 'return_journey_id'
  has_many :bookings, dependent: :destroy, class_name: 'Booking'
  belongs_to :team
  validates_presence_of :team, :start_time, :route
  
  attr_accessor :pickup_stop, :dropoff_stop

  scope :forwards, -> {where("reversed IS NOT TRUE")}
  scope :backwards, -> {where("reversed IS TRUE")}
  scope :available, -> {where('start_time > :start_time AND open_to_bookings IS TRUE AND "full?" IS FALSE', start_time: Time.now)}

  scope :past_or_future, ->(past_or_future) {
    if past_or_future == 'past'
      where('start_time < ?', Time.now).order('start_time DESC')
    elsif past_or_future == 'future'
      where('start_time > ?', Time.now).order('start_time ASC')
    end
  }
  
  scope :on_date, ->(date) {
    where('start_time >= ? AND start_time <= ?', date.to_date.at_beginning_of_day, date.to_date.at_end_of_day)
  }
  scope :booked_or_empty, ->(booked_or_empty) {
    query = joins('LEFT JOIN bookings as outward_bookings on journeys.id = outward_bookings.journey_id LEFT JOIN bookings as return_bookings on journeys.id = return_bookings.return_journey_id').group('journeys.id')
    booked_or_empty == 'booked' ? query.having('count(outward_bookings) > 0 OR count(return_bookings) > 0') : query.having('count(outward_bookings) = 0 AND count(return_bookings) = 0')
  }
  scope :by_route, ->(route_id) {
    where(route_id: Route.id_with_subroutes(route_id))
  }

  filterrific(
    default_filter_params: {
      past_or_future: 'future'
    },
    available_filters: [
      :past_or_future,
      :on_date,
      :booked_or_empty,
      :by_route
    ]
  )
  
  after_create :close_before_end
  after_update :change_close_time, if: :saved_change_to_start_time?
  
  def self.available_for_places(start_place, destination_place)
    from = Stop.where(place: start_place)
    to = Stop.where(place: destination_place)
    routes = Route.where(id: from.collect(&:route_id) & to.collect(&:route_id)).includes(:stops)
    journeys = routes.map do |route|
      stops = route.stops
      f = from.find { |s| stops.include?(s) }
      t = to.find { |s| stops.include?(s) }
      Journey.available.where(
        route_id: route.id,
        reversed: f.position > t.position,
      ).pluck(:id)
    end.flatten.uniq
    Journey.where(id: journeys)
  end
  
  def duplicate(start_date, end_date, include_days = [0,1,2,3,4,5,6])
    (start_date..end_date).each do |date|
      next unless include_days.include?(date.wday)
      Journey.create(attributes.except('id').merge({
        'start_time' => "#{date.to_s}T#{start_time.strftime('%H:%M')}"
      }))
    end
  end

  def booked_bookings
    bookings.booked
  end

  def editable_by_supplier?(supplier)
    supplier.team == self.team
  end

  def is_booked?
    all_bookings.count > 0
  end

  def seats_left
    seats - booked_bookings.sum(:number_of_passengers)
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
        csv << booking.csv_row(id)
      end
    end
  end
  
  def csv_headers
    Booking.csv_headers + [
      'Outbound or Return',
      'Pickup Time',
      'Pickup Place',
      'Pickup Location',
      'Dropoff Time',
      'Dropoff Place',
      'Dropoff Location'
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
    
    def close_time
      if start_time.hour < 9
        (start_time - 1.day).change({ hour: 15, min: 30 })
      else
        start_time - 4.hours
      end
    end
    
    def close_before_end
      CloseBeforeEnd.enqueue(id, run_at: close_time)
    end
    
    def change_close_time
      QueJob.where("args::json->>0 = '?' AND job_class = 'CloseBeforeEnd'", id).destroy_all
      close_before_end
    end

end
