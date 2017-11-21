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
    @trip = params[:trip]
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
        Your Ride booking from #{@booking.outward_trip.pickup_stop.name} to #{@booking.outward_trip.dropoff_stop.name}
        is confirmed. Your vehicle will pick you up from #{@booking.outward_trip.pickup_landmark.name}
        on #{friendly_date(@booking.journey.start_time)} between #{plus_minus_ten(@booking.outward_trip.pickup_time)}
      """
      if @booking.return_journey
        template += """
          , and returning from #{@booking.return_trip.pickup_name} on #{friendly_date(@booking.return_trip.pickup_time)}
          between #{plus_minus_ten(@booking.return_trip.pickup_time)}
        """
      end
      template += """
      . To amend or cancel your booking please use this form #{cancel_booking_url(@booking.token)}
      """
      template.squish
    end
    
    def verification_code
      "Your verification code is #{@passenger.verification_code}"
    end
    
    def first_alert
      text = """
        Your Ride booking reminder. Your vehicle will collect you tomorrow from
        #{@booking.outward_trip.pickup_name} between #{plus_minus_ten(@booking.outward_trip.pickup_time)}.
        Look out for the Ride sticker in the windscreen. To cancel your booking
        please use this form #{cancel_booking_url(@booking.token)}
      """.squish
      text += ". Don’t forget to pay the driver directly." if @booking.payment_method == 'cash'
    end
        
    def second_alert
      """
        Your Ride is on it’s way. Your pickup point is #{@trip.pickup_name}
        between #{plus_minus_ten(@trip.pickup_time)}. Look out for a vehicle
        with the Ride sticker. If you need to get in touch, please call 01621 855111.
      """.squish
    end
    
    def booking_cancellation
      """
        Your Ride booking on #{friendly_date(@booking.journey.start_time)} at
        #{format_time(@booking.journey.start_time)} from #{@booking.outward_trip.pickup_stop.name}
        has been cancelled. To book a new journey, go to https://bookyourride.co.uk/.
      """.squish
    end
  
    def post_survey
      """
        We hope you enjoyed your Ride. To help us improve the service, please
        share your feedback: #{ENV['POST_SURVEY_LINK']}
      """.squish
    end
  
end
