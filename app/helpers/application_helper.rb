module ApplicationHelper

  def friendly_date(date, length=false)
    if date == Date.today
      'Today'
    elsif date == Date.tomorrow
      'Tomorrow'
    else
      day_format = length ? '%a' : '%A'
      strf_format = "#{day_format}, %-d %b"
      # Append the year if the date we want to parse is next year
      strf_format += ", %Y" if date > Date.today.end_of_year
      date.strftime(strf_format)
    end
  end

  def plus_minus_ten(time)
    t = time.to_time
    final_time = "#{format_time(t - 10.minutes)} – #{format_time(t + 10.minutes)}"
  end

  def grab_phone_number(phone, booking)
    unless booking.passenger_id.nil?
      original = Passenger.find(booking.passenger_id).phone_number
      phone.nil? ? original : "#{phone} - number possibly changed from passenger's original (#{original})"
    end
  end

  def book_journey_submit_label(journey, count, label = nil)
    label = label.nil? ? t('button.book') : label
    if count > 1
      "#{label} (via #{via_point(journey)})"
    else
      label
    end
  end

  def via_point(journey)
    points = [journey.pickup_stop.position, journey.dropoff_stop.position].sort
    mid = (points.length - 1) / 2.0
    median = ((points[mid.floor] + points[mid.ceil]) / 2.0).to_i
    journey.route.stops[median].place.name
  end

  def format_time(time)
    (time).strftime("%l:%M%P")
  end

end
