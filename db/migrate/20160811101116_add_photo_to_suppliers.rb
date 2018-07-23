class AddPhotoToSuppliers < ActiveRecord::Migration[4.2]
  def self.up
    add_attachment :suppliers, :photo
  end

  def self.down
    remove_attachment :suppliers, :photo
  end
end
