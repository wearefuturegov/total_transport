class AddPhotoToFriends < ActiveRecord::Migration
  def self.up
    add_attachment :passengers, :photo
  end

  def self.down
    remove_attachment :passengers, :photo
  end
end
