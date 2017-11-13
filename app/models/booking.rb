class Booking < ActiveRecord::Base
  belongs_to :journey
  belongs_to :return_journey, class_name: 'Journey'
  belongs_to :pickup_stop, class_name: 'Stop'
  belongs_to :dropoff_stop, class_name: 'Stop'
  belongs_to :passenger
  belongs_to :promo_code
  belongs_to :pickup_landmark, class_name: 'Landmark'
  belongs_to :dropoff_landmark, class_name: 'Landmark'

  scope :booked, -> { where(state: 'booked') }
  
  after_update :cancel, if: ->(booking) { booking.state == 'cancelled' }
  before_create :generate_token
  
  def self.initialize_for_places(from_place, to_place)
    available_journeys = Journey.available_for_places(from_place, to_place).group_by(&:route)
    available_journeys.map do |route, journeys|
      Booking.new(
        pickup_stop: journeys.first.pickup_stop,
        dropoff_stop: journeys.first.dropoff_stop,
        journey: journeys.first,
      )
    end
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
    @price_distance ||= pickup_stop.distance_to(dropoff_stop)
  end

  def reversed?
    pickup_stop.position > dropoff_stop.position
  end

  def set_promo_code(code)
    self.promo_code = PromoCode.find_by_code(code)
  end

  def price
    if return_journey?
      return_price
    else
      single_price
    end
  end

  def adult_single_price
    if price_distance < 2
      2.5
    elsif price_distance >= 2 && price_distance <= 5
      4.5
    elsif price_distance > 5
      5.5
    end
  end

  def adult_return_price
    if price_distance < 2
      3.5
    elsif price_distance >= 2 && price_distance <= 5
      6.5
    elsif price_distance > 5
      8
    end
  end

  def child_single_price
    if price_distance < 2
      1.5
    elsif price_distance >= 2 && price_distance <= 5
      2.5
    elsif price_distance > 5
      3
    end
  end

  def child_return_price
    if price_distance < 2
      2
    elsif price_distance >= 2 && price_distance <= 5
      3.5
    elsif price_distance > 5
      4.5
    end
  end

  def single_price
    p = (number_of_adult_tickets * adult_single_price) + (child_tickets * child_single_price)
    if promo_code
      p -= promo_code.price_deduction
      p = 0 if p < 0
    end
    p
  end

  def return_price
    p = (number_of_adult_tickets * adult_return_price) + (child_tickets * child_return_price)
    if promo_code
      p -= promo_code.price_deduction
      p = 0 if p < 0
    end
    p
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
  
  def confirm!
    send_confirmation!
    queue_alerts
    update_attribute(:state, 'booked')
    journey.update_attribute(:booked, true)
    return_journey.update_attribute(:booked, true) if return_journey
    log_booking
  end
  
  def queue_sms
    SendSMS.enqueue(to: self.phone_number, template: :booking_notification, booking: self.id)
    SendSMS.enqueue(to: phone_number, template: :first_alert, booking: self.id, run_at: outward_trip.pickup_time - 24.hours)
    SendSMS.enqueue(to: phone_number, template: :second_alert, booking: self.id, run_at: outward_trip.pickup_time - 1.hours)
  end
  
  def queue_emails
    SendEmail.enqueue('BookingMailer', :user_confirmation, booking_id: id)
    SendEmail.enqueue('BookingMailer', :first_alert, booking_id: id, run_at: outward_trip.pickup_time - 24.hours)
    SendEmail.enqueue('BookingMailer', :second_alert, booking_id: id, run_at: outward_trip.pickup_time - 1.hours)
  end
  
  def send_confirmation!
    SendEmail.enqueue('BookingMailer', :booking_confirmed, booking_id: id)
  end
  
  def log_booking
    LogBooking.enqueue(id)
  end
  
  def queue_alerts
    queue_sms if phone_number
    queue_emails if email
  end
  
  def remove_alerts
    #????
  end
  
  def set_journey_booked_status
    journey.update_attribute(:booked, false) if journey.booked_bookings.count == 0
  end
  
  def csv_row(journey)
    if self.journey.id == journey.id
      outward_trip.row_data
    else
      return_trip.row_data
    end
  end
  
  def spreadsheet_row
    [
      [
        passenger_name,
        phone_number,
        pickup_stop.name,
        dropoff_stop.name,
        pickup_landmark.name,
        dropoff_landmark.name,
        journey.time_at_stop(pickup_stop).to_s,
        return_journey.try(:time_at_stop, dropoff_stop).try(:to_s),
        price
      ]
    ]
  end
  
  private
    
    def cancel
      remove_alerts
      set_journey_booked_status
    end
  
    def generate_token
      self.token = loop do
        random_token = SecureRandom.urlsafe_base64(nil, false)
        break random_token unless Booking.exists?(token: random_token)
      end
    end
  
end
