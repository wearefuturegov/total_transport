class AddAllowConcessionsToRoute < ActiveRecord::Migration
  def change
    add_column :routes, :allow_concessions, :boolean, default: true
  end
end
