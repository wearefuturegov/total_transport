class AddNameToPassengers < ActiveRecord::Migration[4.2]
  def change
    add_column :passengers, :name, :string
  end
end
