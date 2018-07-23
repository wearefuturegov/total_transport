class AddSessionTokenToPassengers < ActiveRecord::Migration[4.2]
  def change
    add_column :passengers, :session_token, :string, limit: 40
    add_index :passengers, :session_token, unique: true
  end
end
