class AddEmailToBookings < ActiveRecord::Migration[4.2]
  def change
    add_column :bookings, :email, :string
  end
end
