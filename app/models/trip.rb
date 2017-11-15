class Trip
  include ActiveModel::Model
  
  attr_accessor :journey
  attr_accessor :booking
  
  def pickup_time
    journey.time_at_stop(pickup_stop)
  end
  
  def dropoff_time
    journey.time_at_stop(dropoff_stop)
  end
  
  def pickup_name
    "#{pickup_landmark.name}, #{pickup_stop.name}"
  end
  
  def dropoff_name
    "#{dropoff_landmark.name}, #{dropoff_stop.name}"
  end
  
  def pickup_stop
    outward? ? booking.pickup_stop : booking.dropoff_stop
  end
  
  def dropoff_stop
    outward? ? booking.dropoff_stop : booking.pickup_stop
  end
  
  def pickup_landmark
    outward? ? booking.pickup_landmark : booking.dropoff_landmark
  end
  
  def dropoff_landmark
    outward? ? booking.dropoff_landmark : booking.pickup_landmark
  end
  
  def outward?
    @journey.nil?
  end
  
  def journey
    @journey || booking.journey
  end
  
  def type
    outward? ? 'outward' : 'return'
  end
  
  def row_data
    [
      journey.start_time.to_date,
      booking.passenger_name,
      booking.phone_number,
      booking.email,
      booking.number_of_adults,
      booking.child_tickets,
      booking.price,
      booking.payment_method == 'card' ? 'y' : 'n',
      type,
      pickup_time,
      pickup_stop.name,
      pickup_landmark.name,
      dropoff_time,
      dropoff_stop.name,
      dropoff_landmark.name,
      booking.special_requirements,
      booking.created_at
    ]
  end
  
end
