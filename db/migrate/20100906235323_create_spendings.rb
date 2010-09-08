class CreateSpendings < ActiveRecord::Migration
  def self.up
    create_table :spendings do |t|
      t.date :spending_date
      t.string :spending_details
      t.decimal :spending_amount, :precision => 6, :scale => 2
      t.integer :user_id

      t.timestamps
    end
    add_index :spendings, :user_id
  end

  def self.down
    drop_table :spendings
  end
end
