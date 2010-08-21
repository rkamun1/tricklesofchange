class AddBankToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :daily_bank, :decimal, :precision => 6, :scale => 2
    add_column :users, :savings, :decimal, :precision => 6, :scale => 2
  end

  def self.down
    remove_column :users, :savings
    remove_column :users, :daily_bank
  end
end
