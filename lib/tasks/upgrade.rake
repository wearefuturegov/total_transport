task :upgrade => :environment do
  # Create a supplier account
  # Create a vehicle
  Journey.all.each do |journey|
    journey.supplier = Supplier.first
    journey.vehicle = Vehicle.first
    journey.save!
  end
end
