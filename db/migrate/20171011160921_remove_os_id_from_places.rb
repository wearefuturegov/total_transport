class RemoveOsIdFromPlaces < ActiveRecord::Migration[4.2]
  def change
    remove_column :places, :os_id, :string
  end
end
