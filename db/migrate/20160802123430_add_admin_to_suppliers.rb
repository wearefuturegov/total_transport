class AddAdminToSuppliers < ActiveRecord::Migration
  def change
    add_column :suppliers, :admin, :boolean
  end
end
