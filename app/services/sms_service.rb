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
    @client.api.account.messages.create(
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
      template = I18n.t('sms.booking_notification.single',
        pickup_landmark: @booking.outward_trip.pickup_landmark.name,
        pickup_stop: @booking.outward_trip.pickup_stop.name,
        dropoff_stop: @booking.outward_trip.dropoff_stop.name,
        pickup_date: friendly_date(@booking.journey.start_time),
        pickup_time: plus_minus_ten(@booking.outward_trip.pickup_time)
      )
      template += I18n.t('sms.booking_notification.return',
        pickup_landmark: @booking.return_trip.pickup_landmark.name,
        pickup_stop: @booking.return_trip.pickup_stop.name,
        pickup_date: friendly_date(@booking.journey.start_time),
        pickup_time: plus_minus_ten(@booking.return_trip.pickup_time)
      ) if @booking.return_journey
      template += I18n.t('sms.booking_notification.payment',
        amount: ActionController::Base.helpers.number_to_currency(@booking.price, unit: '£')
      ) if @booking.payment_method == 'cash'
      template += I18n.t('sms.booking_notification.amend_cancel',
        url: cancel_booking_url(@booking.token)
      )
      template.squish
    end
    
    def verification_code
      "Your verification code is #{@passenger.verification_code}"
    end
    
    def first_alert
      template = I18n.t('sms.first_alert.body',
        pickup_name: @booking.outward_trip.pickup_name,
        pickup_time: plus_minus_ten(@booking.outward_trip.pickup_time)
      )
      template += I18n.t('sms.first_alert.payment') if @booking.payment_method == 'cash'
      template += I18n.t('sms.first_alert.cancel',
        url: cancel_booking_url(@booking.token)
      )
      template.squish
    end
        
    def second_alert
      I18n.t('sms.second_alert.body',
        pickup_name: @trip.pickup_name,
        pickup_time: plus_minus_ten(@trip.pickup_time),
        supplier_number: @booking.journey.team.suppliers.first.phone_number
      ).squish
    end
    
    def booking_cancellation
      I18n.t('sms.booking_cancellation.body',
        pickup_date: friendly_date(@booking.journey.start_time),
        pickup_time: format_time(@booking.journey.start_time),
        pickup_name: @booking.outward_trip.pickup_stop.name
      ).squish
    end
  
    def post_survey
      I18n.t('sms.post_survey.body', url: ENV['POST_SURVEY_LINK']).squish
    end
  
end
