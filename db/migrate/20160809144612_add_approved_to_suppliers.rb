class AddApprovedToSuppliers < ActiveRecord::Migration[4.2]
  def change
    add_column :suppliers, :approved, :boolean, :default => false, :null => false
    add_index  :suppliers, :approved
  end
end
