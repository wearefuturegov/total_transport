class AddPhotoToVehicles < ActiveRecord::Migration
  def self.up
    add_attachment :vehicles, :photo
  end

  def self.down
    remove_attachment :vehicles, :photo
  end
end
