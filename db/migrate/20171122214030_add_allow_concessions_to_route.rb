class AddAllowConcessionsToRoute < ActiveRecord::Migration[4.2]
  def change
    add_column :routes, :allow_concessions, :boolean, default: true
  end
end
