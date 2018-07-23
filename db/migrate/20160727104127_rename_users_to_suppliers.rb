class RenameUsersToSuppliers < ActiveRecord::Migration[4.2]
  def change
    rename_table :users, :suppliers
    rename_column :journeys, :user_id, :supplier_id
  end
end
