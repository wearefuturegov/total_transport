class AddNameToRoute < ActiveRecord::Migration[4.2]
  def change
    add_column :routes, :name, :text
  end
end
