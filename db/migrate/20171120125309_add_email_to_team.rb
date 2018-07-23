class AddEmailToTeam < ActiveRecord::Migration[4.2]
  def change
    add_column :teams, :email, :string
  end
end
