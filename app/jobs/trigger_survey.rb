class TriggerSurvey < Que::Job
  include Rails.application.routes.url_helpers

  def run(params)
    begin
      booking = Booking.find(params[:booking])
      return if booking.survey_sent?
      client = Twilio::REST::Client.new
      client.studio.v1.flows(ENV['TWILIO_FLOW_ID']).engagements.create(
        to: booking.phone_number,
        from: ENV['TWILIO_PHONE_NUMBER'],
        parameters: {
          booking_url: booking_url(booking),
          token: booking.token
        }.to_json
      )
      booking.survey_sent = true
      booking.save
    rescue ActiveRecord::RecordNotFound
      destroy
    end
  end

end
