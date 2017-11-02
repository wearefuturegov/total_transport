desc 'Create dummy journeys for demo'
namespace :journeys do
  task :create => :environment do
    if DateTime.now.wday == 0 || ENV['OVERRIDE']
      DataSeed.create_journeys
    end
  end
end
