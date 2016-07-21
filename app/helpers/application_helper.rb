module ApplicationHelper
  def padded_time(time)
    (time - 10.minutes).strftime("%H:%M") +
    " - " +
    (time + 10.minutes).strftime("%H:%M")
  end
end
