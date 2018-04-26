class MovePersonalDataToPassenger < ActiveRecord::Migration
  def change
    add_column :passengers, :email, :string
    Booking.all.each do |b|
      passenger = (b.passenger || Passenger.new)
      passenger.email = b.email
      passenger.name = b.passenger_name
      passenger.phone_number = b.phone_number if passenger.phone_number.nil?
      passenger.save
    end
    remove_column :bookings, :passenger_name, :string
    remove_column :bookings, :email, :string
  end
end
