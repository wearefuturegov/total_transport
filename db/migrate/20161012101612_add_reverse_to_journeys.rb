class AddReverseToJourneys < ActiveRecord::Migration[4.2]
  def change
    add_column :journeys, :reversed, :boolean
  end
end
