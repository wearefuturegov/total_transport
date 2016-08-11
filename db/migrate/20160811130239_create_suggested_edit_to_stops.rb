class CreateSuggestedEditToStops < ActiveRecord::Migration
  def change
    create_table :suggested_edit_to_stops do |t|
      t.references :passenger, index: true, foreign_key: true
      t.references :stop, index: true, foreign_key: true
      t.text :description

      t.timestamps null: false
    end
  end
end
