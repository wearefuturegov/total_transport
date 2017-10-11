client_secret = if ENV['GDRIVE_AUTH']
  StringIO.new(Base64.decode64(ENV['GDRIVE_AUTH']))
else
  'client_secret.json'
end

$google_drive_session = GoogleDrive::Session.from_service_account_key(client_secret)
