class AddSpendingBalanceToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :spending_balance, :decimal, :precision => 6, :scale => 2
  end

  def self.down
    remove_column :users, :spending_balance
  end
end
