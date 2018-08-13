class Booking < ApplicationRecord
  include Rails.application.routes.url_helpers
  
  attr_accessor :passenger_email, :passenger_phone_number, :passenger_name
  
  belongs_to :journey
  belongs_to :return_journey, class_name: 'Journey'
  belongs_to :pickup_stop, class_name: 'Stop'
  belongs_to :dropoff_stop, class_name: 'Stop'
  belongs_to :passenger
  belongs_to :promo_code
  belongs_to :pickup_landmark, class_name: 'Landmark'
  belongs_to :dropoff_landmark, class_name: 'Landmark'
  
  delegate :email, :phone_number, :name, to: :passenger
  
  accepts_nested_attributes_for :passenger

  scope :booked, -> { where(state: ['booked', 'successful', 'missed']) }
  
  after_update :cancel, if: ->(booking) { booking.state == 'cancelled' }
  before_create :generate_token
    
  scope :date_from, ->(date) {
    datetime = date.to_datetime
    joins(:journey)
      .where('journeys.start_time > ?', datetime.beginning_of_day)
      .order('start_time DESC')
  }
  
  scope :date_to, ->(date) {
    datetime = date.to_datetime
    joins(:journey)
      .where('journeys.start_time < ?', datetime.end_of_day)
      .order('start_time DESC')
  }
  
  scope :route, ->(route_id) do
    joins(journey: :route).where('journeys.route_id = ? OR routes.route_id = ?', route_id, route_id)
  end
  
  scope :state, ->(state) { where(state: state) }
  
  scope :team, ->(team_id) { joins(:journey).where('team_id = ?', team_id) }
  
  scope :payment_method, ->(payment_method) { where(payment_method: payment_method) }
  
  filterrific(
    default_filter_params: { state: 'booked' },
    available_filters: [
      :route,
      :date_from,
      :date_to,
      :state,
      :team,
      :payment_method
    ]
  )
  
  def self.csv_headers
    [
      'Passenger Name',
      'Passenger Phone Number',
      'Passenger Email',
      'Route',
      'Number of Adults',
      'Number of Children',
      'Number of Bus Passes',
      'Special Requirements',
      'Time Booked',
      'Price Paid',
      'Card Payment?',
      'Stripe Charge ID',
      'Outward Journey Time',
      'Return Journey Time'
    ]
  end
  
  def booking_id
    "RIDE#{id.to_s.rjust(5, '0')}"
  end
  
  def outward_trip
    @outward_trip ||= Trip.new(
      booking: self
    )
  end
  
  def return_trip
    @return_trip ||= Trip.new(
      journey: return_journey,
      booking: self
    ) if return_journey?
  end
  
  def available_journeys(reversed = false)
    if reversed
      Journey.available_for_places(dropoff_stop.place, pickup_stop.place)
    else
      Journey.available_for_places(pickup_stop.place, dropoff_stop.place)
    end
  end
  
  def route
    journey.route
  end

  def past?
    last_dropoff_time < Time.now
  end

  def last_dropoff_time
    (return_trip || outward_trip).dropoff_time
  end

  def future?
    !past?
  end

  def price_distance
    @price_distance ||= pickup_stop.distance_to(dropoff_stop).ceil
  end

  def reversed?
    pickup_stop.position > dropoff_stop.position
  end

  def set_promo_code(code)
    self.promo_code = PromoCode.find_by_code(code)
  end

  def price
    apply_promo_code(return_journey? ? return_price : single_price).round(1)
  end
  
  def price_in_pence
    (price * 100).to_i
  end

  def adult_single_price
    route.pricing_rule.get_single_price(price_distance)
  end

  def child_single_price
    route.pricing_rule.get_child_price(price_distance)
  end
  
  def adult_return_price
    adult_single_price * route.pricing_rule.return_multiplier
  end

  def child_return_price
    child_single_price * route.pricing_rule.return_multiplier
  end
  
  def apply_promo_code(price)
    return price unless promo_code
    p -= promo_code.price_deduction
    [0, p].max
  end

  def single_price
    (number_of_adult_tickets * adult_single_price) + (child_tickets * child_single_price)
  end

  def return_price
    (number_of_adult_tickets * adult_return_price) + (child_tickets * child_return_price)
  end

  def number_of_free_tickets
    older_bus_passes + disabled_bus_passes + scholar_bus_passes
  end

  def number_of_adult_tickets
    number_of_passengers - number_of_free_tickets - child_tickets
  end
  
  def number_of_adults
    number_of_passengers - number_of_concessions
  end
  
  def number_of_concessions
    child_tickets + older_bus_passes + disabled_bus_passes + scholar_bus_passes
  end

  def return_journey?
    !!return_journey
  end
  
  def payment_description
    "#{pickup_stop.name} - #{dropoff_stop.name} on #{journey.start_time}"
  end
  
  def confirm!(stripe_token)
    return if state == 'booked'
    payment = BookingPaymentService.new(self, stripe_token)
    if payment.create === false
      errors.add(:payment, "There was a problem with your card. The message from the provider was: '#{payment.error}'")
      return false
    else
      send_confirmation!
      queue_alerts
      update_attribute(:state, 'booked')
      journey.update_attribute(:booked, true)
      journey.update_attribute(:full?, true) if journey.seats_left <= 0
      return_journey.update_attribute(:booked, true) if return_journey
    end
  end
  
  def queue_sms
    SendSMS.enqueue(to: self.phone_number, template: :booking_notification, booking: self.id)
    SendSMS.enqueue(to: phone_number, template: :first_alert, booking: self.id, run_at: outward_trip.pickup_time - 24.hours)
    SendSMS.enqueue(to: phone_number, template: :second_alert, booking: self.id, trip: :outward_trip, run_at: outward_trip.pickup_time - 1.hours)
    SendSMS.enqueue(to: phone_number, template: :second_alert, booking: self.id, trip: :return_trip, run_at: return_trip.pickup_time - 1.hours) if return_trip
    TriggerSurvey.enqueue(booking: self.id, run_at: last_dropoff_time + 30.minutes)
  end
  
  def queue_emails
    return if email.nil?
    SendEmail.enqueue('BookingMailer', :user_confirmation, booking_id: id)
    SendEmail.enqueue('BookingMailer', :feedback, booking_id: id, run_at: last_dropoff_time + 30.minutes)
  end
  
  def send_confirmation!
    SendEmail.enqueue('BookingMailer', :booking_confirmed, booking_id: id)
  end
  
  def send_cancellation_email!
    SendEmail.enqueue('BookingMailer', :booking_cancelled, booking_id: id)
    SendEmail.enqueue('BookingMailer', :user_cancellation, booking_id: id) unless email.nil?
  end
  
  def send_cancellation_sms!
    SendSMS.enqueue(to: self.phone_number, template: :booking_cancellation, booking: self.id)
  end
  
  def queue_alerts
    queue_sms if phone_number
    queue_emails if email
  end
  
  def remove_alerts
    QueJob.where("args::json->2->>'booking_id' = ? AND job_class = 'SendEmail'", id.to_s).destroy_all
    QueJob.where("args::json->0->>'booking' = ? AND job_class = 'SendSMS'", id.to_s).destroy_all
    QueJob.where("args::json->0->>'booking' = ? AND job_class = 'TriggerSurvey'", id.to_s).destroy_all
  end
  
  def set_journey_booked_status
    journey.update_attribute(:booked, false) if journey.booked_bookings.count == 0
  end
  
  def csv_row(journey_id = nil)
    data = [
      name,
      phone_number,
      email,
      route.name,
      number_of_adults,
      child_tickets,
      number_of_free_tickets,
      special_requirements,
      created_at,
      price,
      payment_method == 'card' ? 'y' : 'n',
      charge_id
    ]
    if journey_id.present?
      data += journey_id == journey.id ? outward_trip.row_data : return_trip.row_data
    else
      data += [ outward_trip.pickup_time, return_trip&.pickup_time ]
    end
    data
  end

  private
    
    def cancel
      remove_alerts
      set_journey_booked_status
      send_cancellation_sms!
      refund! unless charge_id.nil?
      send_cancellation_email!
      journey.update_attribute(:full?, false)
    end
    
    def refund!
      Stripe::Refund.create(charge: charge_id)
    end
  
    def generate_token
      self.token = loop do
        random_token = SecureRandom.urlsafe_base64(nil, false)
        break random_token unless Booking.exists?(token: random_token)
      end
    end
  
end
