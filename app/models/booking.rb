class Booking < ActiveRecord::Base
  belongs_to :journey
  belongs_to :pickup_stop, class_name: 'Stop'
  belongs_to :dropoff_stop, class_name: 'Stop'
  belongs_to :passenger
  belongs_to :payment_method

  scope :booked, -> {where("journey_id IS NOT NULL AND pickup_stop_id IS NOT NULL AND dropoff_stop_id IS NOT NULL AND payment_method_id IS NOT NULL")}

  def route
    journey.route
  end

  def past?
    pickup_stop.time_for_journey(journey) < Time.now
  end

  def future?
    !past?
  end

  def send_notification!(message)
    @client = Twilio::REST::Client.new
    @client.messages.create(
      from: '+441173252034',
      to: self.phone_number,
      body: message
    )
  end
end
