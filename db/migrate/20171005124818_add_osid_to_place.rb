class AddOsidToPlace < ActiveRecord::Migration[4.2]
  def change
    add_column :places, :os_id, :string
  end
end
