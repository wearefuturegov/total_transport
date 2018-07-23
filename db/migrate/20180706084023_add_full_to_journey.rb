class AddFullToJourney < ActiveRecord::Migration[4.2]
  def change
    add_column :journeys, :full?, :boolean, default: false
  end
end
