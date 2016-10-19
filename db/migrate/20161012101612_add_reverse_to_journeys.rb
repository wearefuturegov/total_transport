class AddReverseToJourneys < ActiveRecord::Migration
  def change
    add_column :journeys, :reversed, :boolean
  end
end
