class BookingPaymentService
  include Rails.application.routes.url_helpers
  
  attr_reader :error
  
  def initialize(booking, token)
    @booking = booking
    @token = token
  end
  
  def create
    return nil if @token.blank?
    return false unless charge
    @booking.update_column(:charge_id, @charge_id)
    @booking.update_column(:payment_method, 'card')
  end
  
  def charge
    @charge_id = Stripe::Charge.create(
      customer: customer.id,
      amount:  @booking.price_in_pence,
      description: payment_description,
      currency: 'gbp',
      metadata: metadata
    ).id
  rescue Stripe::CardError => e
    @error = e.message
    false
  end
  
  def customer
    Stripe::Customer.create(source: @token)
  end
  
  def metadata
    metadata = {}
    metadata[:outward_journey_url] = admin_journey_booking_url(@booking.outward_trip.journey, @booking)
    metadata[:return_journey_url] = admin_journey_booking_url(@booking.return_trip.journey, @booking) if @booking.return_trip
    metadata
  end
  
  def payment_description
    "#{@booking.pickup_stop.name} - #{@booking.dropoff_stop.name} on #{@booking.journey.start_time}"
  end
  
end
