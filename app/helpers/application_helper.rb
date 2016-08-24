module ApplicationHelper
  def padded_time(time)
    (time - 10.minutes).strftime("%H:%M") +
    " - " +
    (time + 10.minutes).strftime("%H:%M")
  end

  def friendly_date(date)
    if date == Date.today
      "Today"
    elsif date == Date.yesterday
      "Yesterday"
    elsif (date > Date.today - 7) && (date < Date.yesterday)
      date.strftime("%A")
    elsif (date > Date.today.beginning_of_year) && (date < Date.today.end_of_year)
      date.strftime("%B %-d")
    else
      date.strftime("%B %-d - %Y")
    end
  end
end
