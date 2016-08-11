namespace :maintenance do
  task :close_near_journeys => :environment do
    Journey.close_near_journeys
  end
end
