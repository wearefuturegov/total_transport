namespace :notifications do
  task :send_1_hour_notifications => :environment do
    beginning_of_this_10_mins = Time.at((Time.now.to_f / 10.minutes).floor * 10.minutes).utc
    start_time = beginning_of_this_10_mins + 1.hour
    end_time = start_time + 10.minutes - 1
    bookings = Booking.pickup_between_times(start_time, end_time)
    bookings.each do |booking|
      booking.send_notification!("Reminder: you will be picked up at #{booking.pickup_time.strftime("%I:%M %p")}")
    end
  end

  task :send_24_hour_notifications => :environment do
    beginning_of_this_10_mins = Time.at((Time.now.to_f / 10.minutes).floor * 10.minutes).utc
    start_time = beginning_of_this_10_mins + 24.hours
    end_time = start_time + 10.minutes - 1
    bookings = Booking.pickup_between_times(start_time, end_time)
    bookings.each do |booking|
      booking.send_notification!("Reminder: you will be picked up at #{booking.pickup_time.strftime("%I:%M %p")}")
    end
  end
end
