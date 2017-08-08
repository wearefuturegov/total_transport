desc 'Bootstrap review app'
task :bootstrap do
  heroku = PlatformAPI.connect_oauth(ENV['HEROKU_API_TOKEN'])
  heroku.config_var.update(ENV['HEROKU_APP_NAME'], 'WWW_HOSTNAME' => "#{ENV['HEROKU_APP_NAME']}.herokuapp.com")
end
