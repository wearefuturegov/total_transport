desc 'Create dummy journeys for demo'
namespace :journeys do
  task :create => :environment do
    if DateTime.now.wday == 0 || ENV['OVERRIDE']
      6.times do |i|
        date = Date.today + i.days
        Route.all.each do |r|
          [false, true].each do |b|
            Journey.create(route: r, vehicle_id: 1, supplier_id: 1, open_to_bookings: true, reversed: b, start_time: DateTime.parse("#{date} 08:00:00"))
            Journey.create(route: r, vehicle_id: 1, supplier_id: 1, open_to_bookings: true, reversed: b, start_time: DateTime.parse("#{date} 10:00:00"))
            Journey.create(route: r, vehicle_id: 1, supplier_id: 1, open_to_bookings: true, reversed: b, start_time: DateTime.parse("#{date} 12:00:00"))
            Journey.create(route: r, vehicle_id: 1, supplier_id: 1, open_to_bookings: true, reversed: b, start_time: DateTime.parse("#{date} 13:00:00"))
            Journey.create(route: r, vehicle_id: 1, supplier_id: 1, open_to_bookings: true, reversed: b, start_time: DateTime.parse("#{date} 15:00:00"))
            Journey.create(route: r, vehicle_id: 1, supplier_id: 1, open_to_bookings: true, reversed: b, start_time: DateTime.parse("#{date} 17:00:00"))
          end
        end
      end
    end
  end
end
