class AddFullToJourney < ActiveRecord::Migration
  def change
    add_column :journeys, :full?, :boolean, default: false
  end
end
