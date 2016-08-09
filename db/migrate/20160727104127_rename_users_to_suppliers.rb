class RenameUsersToSuppliers < ActiveRecord::Migration
  def change
    rename_table :users, :suppliers
    rename_column :journeys, :user_id, :supplier_id
  end
end
