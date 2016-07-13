class CreateJourneys < ActiveRecord::Migration
  def change
    create_table :journeys do |t|
      t.references :route, index: true, foreign_key: true
      t.datetime :start_time

      t.timestamps null: false
    end
  end
end
