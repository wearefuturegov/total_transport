require 'open-uri'
desc 'Create places for a specific county'
namespace :places do
  task :create => :environment do
    DataSeed.create_places
  end
end
