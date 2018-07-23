class AddSurveySentToBookings < ActiveRecord::Migration[4.2]
  def change
    add_column :bookings, :survey_sent, :boolean
  end
end
