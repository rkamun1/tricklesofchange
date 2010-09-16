class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.string :details
      t.decimal :cost, :precision => 6, :scale => 2
      t.integer :allotment, :default => 0 #the precentage alloted from the total saved
      t.decimal :accrued, :precision => 6, :scale => 2
      t.integer :user_id

      t.timestamps
    end
    add_index :accounts, :user_id
  end

  def self.down
    drop_table :accounts
  end
end
