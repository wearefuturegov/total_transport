class AddOsidToPlace < ActiveRecord::Migration
  def change
    add_column :places, :os_id, :string
  end
end
