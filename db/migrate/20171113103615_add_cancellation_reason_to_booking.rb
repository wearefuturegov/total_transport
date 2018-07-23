class AddCancellationReasonToBooking < ActiveRecord::Migration[4.2]
  def change
    add_column :bookings, :cancellation_reason, :string
  end
end
