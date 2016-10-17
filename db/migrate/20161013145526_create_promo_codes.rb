class CreatePromoCodes < ActiveRecord::Migration
  def change
    create_table :promo_codes do |t|
      t.decimal :price_deduction
      t.string :code

      t.timestamps null: false
    end
  end
end
