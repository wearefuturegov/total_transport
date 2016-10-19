class AddSpecialRequirementsToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :special_requirements, :text
  end
end
