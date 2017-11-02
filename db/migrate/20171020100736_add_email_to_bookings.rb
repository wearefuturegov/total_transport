class AddEmailToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :email, :string
  end
end
