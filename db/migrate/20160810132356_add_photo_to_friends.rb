class AddPhotoToFriends < ActiveRecord::Migration[4.2]
  def self.up
    add_attachment :passengers, :photo
  end

  def self.down
    remove_attachment :passengers, :photo
  end
end
