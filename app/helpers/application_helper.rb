module ApplicationHelper
  def friendly_date(date, length=false)
    if date == Date.today
      "Today"
    elsif date == Date.tomorrow
      "Tomorrow"
    elsif (date > Date.today.beginning_of_year) && (date < Date.today.end_of_year)
      if length
        date.strftime("%a, %-d %B")
      else
        date.strftime("%A, %-d %B")
      end

    else
      if length
        date.strftime("%a, %-d %B, %Y")
      else
        date.strftime("%A, %-d %B, %Y")
      end
    end
  end

  def plus_minus_ten(time)
    t = time.to_time
    final_time = "#{(t - 10*60).strftime("%l:%M%P")} and #{(t + 10*60).strftime("%l:%M%P")}"
  end

  def num_of_adults(num_of_passengers)
    num_of_adults = num_of_passengers - @booking.child_tickets - @booking.older_bus_passes - @booking.disabled_bus_passes - @booking.scholar_bus_passes
  end

  def grab_phone_number(phone, booking)
    if phone == nil
      final_phone = Passenger.find(booking.passenger_id).phone_number
    else
      final_phone = "#{phone} - number possibly changed from passenger's original (#{Passenger.find(booking.passenger_id).phone_number})"
    end
  end
end
