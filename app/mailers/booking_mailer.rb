class BookingMailer < ActionMailer::Base
  add_template_helper(ApplicationHelper)

  def booking_confirmed(booking)
    @booking = booking
    mail(to: ENV['RIDE_ADMIN_EMAIL'], from: ENV['RIDE_ADMIN_EMAIL'], subject: 'A new booking has been confirmed')
  end

end
