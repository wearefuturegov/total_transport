require 'twilio-ruby'

class SmsService
  include ApplicationHelper
  include Rails.application.routes.url_helpers
    
  cattr_accessor :client
  self.client = Twilio::REST::Client
  
  def initialize(params)
    @client = self.client.new
    @to = params[:to]
    @message = params[:message]
    @template = params[:template]
    @booking = params[:booking]
    @passenger = params[:passenger]
  end
  
  def perform
    @client.messages.create(
      from: TWILIO_PHONE_NUMBER,
      to: @to,
      body: message
    )
  end
  
  def message
    @template.nil? ? @message : send(@template)
  end
  
  def default_url_options
    Rails.application.config.action_mailer.default_url_options
  end
  
  private
    
    def booking_notification
      """
        Your Pickup booking from #{@booking.pickup_stop.name} to #{@booking.dropoff_stop.name}
        is confirmed. Your vehicle will pick you up from #{@booking.pickup_name}
        on #{friendly_date(@booking.journey.start_time)} between #{plus_minus_ten(@booking.pickup_time)}.
        You can review or cancel your booking here: #{passenger_booking_url(@booking.passenger, @booking)}
      """.squish
    end
    
    def verification_code
      "Your verification code is #{@passenger.verification_code}"
    end
    
    def first_alert
      """
        This is a reminder that you will be picked up from #{@booking.pickup_stop.name}
        tomorrow at #{@booking.pickup_time.strftime("%I:%M %p")}. You can review
        or cancel your booking here: #{passenger_booking_url(@booking.passenger, @booking)}
      """.squish
    end
    
    def second_alert
      """
        You will be picked up from #{@booking.pickup_stop.name} today at
        #{@booking.pickup_time.strftime("%I:%M %p")}
      """.squish
    end
    
    def generated_journey
      """
        Good news! We've managed to find a vehicle for your journey from
        #{@booking.pickup_stop.name} to #{@booking.dropoff_stop.name} on
        #{friendly_date(@booking.journey.start_time)}. The rough time for your
        pickup will be #{@booking.pickup_time.strftime("%I:%M %p")}.
        
        To confirm and pay for your booking, please go to
        #{edit_pickup_location_route_booking_url(@booking.route, @booking)}.
      """.squish
    end
  
end
