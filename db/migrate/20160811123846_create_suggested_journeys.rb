class CreateSuggestedJourneys < ActiveRecord::Migration
  def change
    create_table :suggested_journeys do |t|
      t.references :passenger, index: true, foreign_key: true
      t.references :route, index: true, foreign_key: true
      t.datetime :start_time
      t.text :description

      t.timestamps null: false
    end
  end
end
