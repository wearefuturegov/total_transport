class LogBooking < Que::Job
  
  def run(booking_id)
    begin
      booking = Booking.find(booking_id)
      spreadsheet = $google_drive_session.spreadsheet_by_key(ENV['BOOKINGS_SPREADSHEET_KEY'])
      worksheet = spreadsheet.worksheets.first
      worksheet.insert_rows(worksheet.num_rows + 1, booking.spreadsheet_row)
      worksheet.save
    rescue ActiveRecord::RecordNotFound
      destroy
    end
  end

end
