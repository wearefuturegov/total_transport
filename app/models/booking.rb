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
  
  after_destroy :remove_alerts, :set_journey_booked_status
  
  def route
    journey.route
  end

  def past?
    last_dropoff_time < Time.now
  end

  def pickup_time(reversed = false)
    stop = reversed ? dropoff_stop : pickup_stop
    journey.time_at_stop(stop)
  end
  
  def dropoff_time(reversed = false)
    stop = reversed ? pickup_stop : dropoff_stop
    journey.time_at_stop(dropoff_stop)
  end

  def last_dropoff_time
    if return_journey?
      return_journey.time_at_stop(pickup_stop)
    else
      journey.time_at_stop(dropoff_stop)
    end
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
  end
  
  def send_confirmation!
    SendSMS.enqueue(to: self.phone_number, template: :booking_notification, booking: self.id)
  end
  
  def queue_alerts
    SendSMS.enqueue(to: phone_number, template: :first_alert, booking: self.id, run_at: pickup_time - 24.hours)
    SendSMS.enqueue(to: phone_number, template: :second_alert, booking: self.id, run_at: pickup_time - 1.hours)
  end
  
  def remove_alerts
    #????
  end
  
  def set_journey_booked_status
    journey.update_attribute(:booked, false) if journey.bookings.count == 0
  end

end
