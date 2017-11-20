class BookingMailer < ActionMailer::Base
  add_template_helper(ApplicationHelper)
    
  default from: "Ride <#{ENV['RIDE_ADMIN_EMAIL']}>", to: Proc.new { @booking.email }

  def booking_confirmed(params)
    @booking = Booking.find(params['booking_id'])
    mail(to: @booking.journey.supplier.team.email, subject: 'A new booking has been confirmed')
  end
  
  def booking_cancelled(params)
    @booking = Booking.find(params['booking_id'])
    mail(to: @booking.journey.supplier.team.email, subject: 'Booking cancelled')
  end
  
  def user_confirmation(params)
    @booking = Booking.find(params['booking_id'])
    mail(subject: 'Your Ride booking confirmation')
  end

end
