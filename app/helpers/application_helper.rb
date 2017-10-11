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
    final_time = "#{format_time(t - 10.minutes)} and #{format_time(t + 10.minutes)}"
  end

  def grab_phone_number(phone, booking)
    unless booking.passenger_id.nil?
      original = Passenger.find(booking.passenger_id).phone_number
      phone.nil? ? original : "#{phone} - number possibly changed from passenger's original (#{original})"
    end
  end
  
  private
  
    def format_time(time)
      (time).strftime("%l:%M%P")
    end
  
end
