module ApplicationHelper
  def padded_time(time)
    (time - 10.minutes).strftime("%l:%M%P") +
    " - " +
    (time + 10.minutes).strftime("%l:%M%P")
  end

  def friendly_date(date)
    if date == Date.today
      "Today"
    elsif date == Date.tomorrow
      "Tomorrow"
    elsif (date > Date.today.beginning_of_year) && (date < Date.today.end_of_year)
      date.strftime("%A, %-d %B")
    else
      date.strftime("%A, %-d %B, %Y")
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
