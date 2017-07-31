class AddSessionTokenToPassengers < ActiveRecord::Migration
  def change
    add_column :passengers, :session_token, :string, limit: 40
    add_index :passengers, :session_token, unique: true
  end
end
