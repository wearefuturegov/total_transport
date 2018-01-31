class BookingMailer < ActionMailer::Base
  add_template_helper(ApplicationHelper)
    
  default from: "Ride <#{ENV['RIDE_ADMIN_EMAIL']}>", to: Proc.new { @booking.email }

  def booking_confirmed(params)
    @booking = Booking.find(params['booking_id'])
    mail(to: @booking.journey.team.email, cc: ENV['RIDE_ADMIN_EMAIL'], subject: "A new booking has been confirmed (ref: #{@booking.booking_id})")
  end
  
  def booking_cancelled(params)
    @booking = Booking.find(params['booking_id'])
    mail(to: @booking.journey.team.email, cc: ENV['RIDE_ADMIN_EMAIL'], subject: 'Booking cancelled')
  end
  
  def user_confirmation(params)
    @booking = Booking.find(params['booking_id'])
    mail(subject: 'Your Ride booking confirmation')
  end
  
  def user_cancellation(params)
    @booking = Booking.find(params['booking_id'])
    mail(subject: 'Ride booking cancellation')
  end

  def feedback(params)
    @booking = Booking.find(params['booking_id'])
    mail(subject: 'We hope you enjoyed your Ride')
  end

end
