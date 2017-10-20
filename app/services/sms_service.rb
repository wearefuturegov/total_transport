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
      template = """
        Your Ride booking from #{@booking.pickup_stop.name} to #{@booking.dropoff_stop.name}
        is confirmed. Your vehicle will pick you up from #{@booking.pickup_name},
        on #{friendly_date(@booking.journey.start_time)} between #{plus_minus_ten(@booking.pickup_time)}
      """
      if @booking.return_journey
        template += """
          , and returning from #{@booking.dropoff_name} on #{friendly_date(@booking.return_journey.start_time)}
          between #{plus_minus_ten(@booking.return_time)}
        """
      end
      template += """
      . To amend or cancel your booking please call 01621 855111
      """
      template.squish
    end
    
    def verification_code
      "Your verification code is #{@passenger.verification_code}"
    end
    
    def first_alert
      """
        Your Ride booking reminder. You will be picked up from #{@booking.pickup_name}
        tomorrow between #{plus_minus_ten(@booking.pickup_time)}. Don’t forget to pay the driver directly.
        To amend or cancel your booking please call 01621 855111
      """.squish
    end
    
    #Your Ride is on it’s way. Your pickup point is <stop>, <location> at <time>. Look out for a vehicle with the Ride sticker. If you need to get in touch, please call <supplier number>.
    
    def second_alert
      """
        Your Ride is on it’s way. Your pickup point is #{@booking.pickup_name}
        between #{plus_minus_ten(@booking.pickup_time)}. Look out for a vehicle
        with the Ride sticker. If you need to get in touch, please call 01621 855111.
      """.squish
    end
  
end
