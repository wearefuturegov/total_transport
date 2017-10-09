class TrackFailedPlaceQuery < Que::Job
  
  def run(name, type)
    spreadsheet = $google_drive_session.spreadsheet_by_key(ENV['STATS_SPREADSHEET_KEY'])
    worksheet = spreadsheet.worksheets.first
    worksheet.insert_rows(worksheet.num_rows + 1, [[name, type]])
    worksheet.save
    destroy
  end
  
end
