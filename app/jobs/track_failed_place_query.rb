class TrackFailedPlaceQuery < Que::Job
  
  def run(origin, destination, datetime)
    spreadsheet = $google_drive_session.spreadsheet_by_key(ENV['STATS_SPREADSHEET_KEY'])
    worksheet = spreadsheet.worksheets.first
    worksheet.insert_rows(worksheet.num_rows + 1, [[origin, destination, datetime]])
    worksheet.save
    destroy
  end
  
end
