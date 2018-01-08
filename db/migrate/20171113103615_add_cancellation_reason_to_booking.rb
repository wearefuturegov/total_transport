class AddCancellationReasonToBooking < ActiveRecord::Migration
  def change
    add_column :bookings, :cancellation_reason, :string
  end
end
