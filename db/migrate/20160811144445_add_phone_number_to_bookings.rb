class AddPhoneNumberToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :phone_number, :string
  end
end
