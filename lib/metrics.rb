class Metrics
  
  def self.run
    metric = self.new
    metric.record
  end
  
  def record
    worksheet = spreadsheet.worksheets.first
    worksheet.insert_rows(worksheet.num_rows + 1, [row])
    worksheet.save
  end
  
  def row
    [
      Date.today.to_s,
      bookings_count,
      passenger_count,
      cancelled_count,
      cash_payments,
      card_payments
    ]
  end
  
  def card_payments
    booked_bookings.where(payment_method: 'card').count
  end
  
  def cash_payments
    booked_bookings.where(payment_method: 'cash').count
  end
  
  def cancelled_count
    scope.where(state: 'cancelled').count
  end
  
  def passenger_count
    booked_bookings.sum(:number_of_passengers)
  end
  
  def bookings_count
    booked_bookings.count
  end
  
  private
  
    def booked_bookings
      @booked_bookings ||= scope.where(state: 'booked')
    end
    
    def spreadsheet
      $google_drive_session.spreadsheet_by_key(ENV['METRICS_SPREADSHEET_KEY'])
    end
    
    def scope
      Booking.where('updated_at BETWEEN ? AND ?', 1.week.ago, DateTime.now)
    end
  
end
