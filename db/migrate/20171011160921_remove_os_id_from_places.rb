class RemoveOsIdFromPlaces < ActiveRecord::Migration
  def change
    remove_column :places, :os_id, :string
  end
end
