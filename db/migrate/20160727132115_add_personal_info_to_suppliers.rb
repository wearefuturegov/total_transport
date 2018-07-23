class AddPersonalInfoToSuppliers < ActiveRecord::Migration[4.2]
  def change
    add_column :suppliers, :name, :string
    add_column :suppliers, :phone_number, :string
  end
end
