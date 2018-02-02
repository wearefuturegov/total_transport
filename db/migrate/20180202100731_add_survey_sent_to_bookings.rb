class AddSurveySentToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :survey_sent, :boolean
  end
end
