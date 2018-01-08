task :metrics => :environment do
  if DateTime.now.wday == 1 || ENV['OVERRIDE']
    Metrics.run
  end
end
