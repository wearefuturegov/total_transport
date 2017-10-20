class BookingMailer < ActionMailer::Base
  add_template_helper(ApplicationHelper)

  def booking_confirmed(booking)
    @booking = booking
    mail(to: ENV['RIDE_ADMIN_EMAIL'], from: ENV['RIDE_ADMIN_EMAIL'], subject: 'A new booking has been confirmed')
  end
  
  def user_confirmation(booking)
    @booking = booking
    mail(to: booking.email, from: ENV['RIDE_ADMIN_EMAIL'], subject: 'Your Ride booking confirmation')
  end
  
  def first_alert(booking)
    @booking = booking
    mail(to: booking.email, from: ENV['RIDE_ADMIN_EMAIL'], subject: 'Your Ride booking is tomorrow')
  end
  
  def second_alert(booking)
    @booking = booking
    mail(to: booking.email, from: ENV['RIDE_ADMIN_EMAIL'], subject: 'Your Ride is on it’s way.')
  end

end
