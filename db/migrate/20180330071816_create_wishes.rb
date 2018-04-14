class CreateWishes < ActiveRecord::Migration[5.1]
  def change
    create_table :wishes do |t|
      t.string :wish
      t.string :coin
      t.string :payment_hash

      t.timestamps
    end
  end
end