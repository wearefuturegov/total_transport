class AddApprovedToSuppliers < ActiveRecord::Migration
  def change
    add_column :suppliers, :approved, :boolean, :default => false, :null => false
    add_index  :suppliers, :approved
  end
end
