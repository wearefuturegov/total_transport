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
  
  private
    
    def booking_notification
      """
        Your Pickup booking from #{@booking.pickup_stop.name} to #{@booking.dropoff_stop.name}
        is confirmed. Your vehicle will pick you up from #{@booking.pickup_name}
        on #{friendly_date(@booking.journey.start_time)} between
        #{plus_minus_ten(@booking.pickup_stop.time_for_journey(@booking.journey))}.
        You can review or cancel your booking here: #{passenger_booking_url(@booking)}
      """.squish
    end
    
    def verification_code
      "Your verification code is #{@passenger.verification_code}"
    end
    
    def pickup_alert
      "Reminder: you will be picked up at #{@booking.pickup_time.strftime("%I:%M %p")}"
    end
  
end
