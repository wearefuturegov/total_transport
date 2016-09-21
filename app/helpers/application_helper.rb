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

  def payment_class(payment_method_type)
    payment_method_type = payment_method_type.to_s
    if payment_method_type == 'paypal'
      'fa-paypal'
    elsif payment_method_type == 'apple_pay'
      'fa-apple'
    elsif payment_method_type == 'credit_card'
      'fa-credit-card-alt'
    elsif payment_method_type == 'google_pay'
      'fa-google-wallet'
    elsif payment_method_type == 'cash'
      'fa-money'
    end
  end
end
